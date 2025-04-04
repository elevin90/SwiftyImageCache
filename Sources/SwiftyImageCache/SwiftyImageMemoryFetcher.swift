//
//  SwiftyImageMemoryFetcher.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/1/25.
//

import Foundation
import CryptoKit

/// Protocol for file manager logic
protocol ImageFileManaging {
  func fileExists(atPath path: String) -> Bool
  func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
  func attributesOfFileSystem(forPath path: String) throws -> [FileAttributeKey : Any]
  func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
}

/// An object which is responsible for fetching image data from cache or persistant storage if the image data can be found
final class SwiftyImageMemoryFetcher {
  /// Temporaly cache
  private let memoryCache: NSCache<NSURL, NSData>
  /// File manager instance
  private let fileManager: ImageFileManaging
  /// Directory where cached images are stored on disk.
  private let cacheDirectoryURL: URL
  
  /// An object which is responsible for fetching image data from cache or persistant storage if the image data can be found
  /// - Parameter fileManager: File manager instance which conforms to ImageFileManaging protocol
  init(fileManager: ImageFileManaging = FileManager.default) {
    guard let caches = fileManager.urls(
      for: .cachesDirectory,
      in: .userDomainMask
    ).first else {
      fatalError("Could not retrieve caches directory")
    }
    self.memoryCache = NSCache<NSURL, NSData>()
    self.fileManager = fileManager
    self.cacheDirectoryURL = caches.appendingPathComponent("SwiftyImageCache")
  }
  
  /// Retrives image data  if it  can be found
  /// - Parameter key: Key for image
  /// - Returns: Image data  if it  can be found, otherwise returns nil
  func imageData(forKey key: URL) throws -> Data? {
    let hashedKey = hashedFileKey(for: key)
    if let cachedImageData = memoryCache.object(forKey: hashedKey as NSURL) {
        return cachedImageData as Data
    }
    if let diskCacheImageData = try fetchFromDiskCache(from: hashedKey) {
      return diskCacheImageData
    }
    return nil
  }
  
  /// Saves image data fir given url key
  /// - Parameters:
  ///   - data: Image binary
  ///   - key: Given url key
  func setImageData(_ data: Data, forKey key: URL) throws {
    let hashedKey = hashedFileKey(for: key)
    memoryCache.setObject(data as NSData, forKey: hashedKey as NSURL)
    do {
      if try hasSufficientDiskSpace(for: data) {
        try saveToStorage(url: hashedKey, data: data)
      }
    } catch {
      print(error)
    }
  }
  
  /// Checks if there is enough disk space to store the given data.
  /// - Parameter data: The image data to be cached.
  /// - Returns: `true` if there is sufficient space, otherwise `false`.
  func hasSufficientDiskSpace(for data: Data) throws -> Bool {
    let freeSpace = try getSpaceAmount()
    return freeSpace > Int64(data.count)
  }
}

// MARK: Utitlity methods

private extension SwiftyImageMemoryFetcher {
  /// Saves the image data to both memory and disk caches.
  /// - Parameters:
  ///   - url: The URL of the image.
  ///   - data: The image data.
  func saveToStorage(url: URL, data: Data) throws {
    let filePath = cacheDirectoryURL.appendingPathComponent(url.lastPathComponent)
    try? data.write(to: filePath)
  }

  /// Retrieves image data from disk cache cache if available
  /// - Returns: Image binary data
  func fetchFromDiskCache(from url: URL) throws -> Data? {
    let filePath = cacheDirectoryURL.appendingPathComponent(url.lastPathComponent)
    if fileManager.fileExists(atPath: filePath.path) {
      do {
        let data = try Data(contentsOf: filePath)
        memoryCache.setObject(data as NSData, forKey: url as NSURL)
        return data
      } catch {
        throw SwiftyImageCacheError.fileError(error)
      }
    }
    return nil
  }
  
  /// Retrieves the available free space on the device.
  /// - Returns: Free space in bytes.
  func getSpaceAmount() throws -> Int64 {
    do {
      let attributes = try fileManager.attributesOfFileSystem(
        forPath: NSHomeDirectory()
      )
      return attributes[.systemFreeSize] as? Int64 ?? .zero
    } catch {
      throw SwiftyImageCacheError.unableToCalculateFreeSpace
    }
  }

  /// Utitlity method for hashing image url path
  /// - Parameter url: Image URL
  /// - Returns: Returns unique hashed image url
  func hashedFileKey(for url: URL) -> URL {
    let pathWithParams = url.path + (url.query.map { "?\($0)" } ?? "")
    let data = Data(pathWithParams.utf8)
    let hash = SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    
    guard let baseURL = url.scheme.flatMap({ URL(string: "\($0)://\(url.host ?? "")/") }) else {
      return url
    }
    return baseURL.appendingPathComponent(hash)
  }
}

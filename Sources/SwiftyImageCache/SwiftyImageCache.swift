// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - SwiftyImageCaching Protocol

/// A protocol defining the caching behavior for images.
/// Conforming types should provide an implementation for loading images
/// with a specified priority and a method to clear the cache.
protocol SwiftyImageCaching {
  /// Loads an image from a given URL, either from cache or by fetching it from the network.
  /// - Parameters:
  ///   - url: The URL of the image to load.
  ///   - priority: The priority level for fetching the image.
  /// - Returns: The image data if successful.
  /// - Throws: `SwiftyImageCacheError` if loading fails.
  func loadImage(
    from url: URL,
    priority: ImageLoadPriority
  ) async throws -> Data
}

enum SwiftyImageCacheError: Error {
  /// Error indicating that the free space on the device could not be determined.
  case unableToCalculateFreeSpace
  /// Error indicating a network failure occurred while fetching an image.
  case networkError(Error)
  /// Error indicating an issue with reading or writing image files.
  case fileError(Error)
  /// A generic error case for unknown failures.
  case unknown
}

/// An image caching object that stores images in both memory and disk.
actor SwiftyImageCache: SwiftyImageCaching {
  /// Shared instance of the image cache.
  static let shared = SwiftyImageCache()

  /// In-memory cache for quick access to frequently used images.
  private let memoryCache = NSCache<NSURL, NSData>()

  /// File manager instance for handling disk cache operations.
  private let fileManager = FileManager.default

  /// Directory where cached images are stored on disk.
  private let cacheDirectoryURL: URL

  /// Private initializer to enforce singleton usage.
  private init() {
    guard let caches = fileManager.urls(
      for: .cachesDirectory,
      in: .userDomainMask
    ).first else {
      fatalError("Could not retrieve caches directory")
    }
    self.cacheDirectoryURL = caches.appendingPathComponent("SwiftyImageCache")
    
    if !fileManager.fileExists(atPath: cacheDirectoryURL.path) {
      try? fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
    }
  }

  /// Loads an image from cache or downloads it if not found.
  /// - Parameters:
  ///   - url: The URL of the image to load.
  ///   - priority: The priority for network fetching.
  /// - Returns: The image data.
  /// - Throws: `SwiftyImageCacheError` if loading fails.
  func loadImage(from url: URL, priority: ImageLoadPriority) async throws -> Data {
    // Check memory cache
    if let cachedData = fetchFromCache(from: url) {
      return cachedData
    }
    // Check in disk cache directory
    if let diskCashedData = try fetchFromDiskCache(from: url) {
      return diskCashedData
    }
    // Download image, save and provide binary
    do {
      let imageData = try await fetchRemoteImageData(from: url, with: priority)
      if try hasSufficientDiskSpace(for: imageData) {
        saveToCache(url: url, data: imageData)
      }
      return imageData
    } catch {
      throw SwiftyImageCacheError.networkError(error)
    }
  }
}

// MARK: Image Data Fetching

private extension SwiftyImageCache {
  func fetchFromCache(from url: URL) -> Data? {
    memoryCache.object(forKey: url as NSURL) as Data?
  }
  
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
  
  func fetchRemoteImageData(from url: URL, with priority: ImageLoadPriority) async throws -> Data {
    let session = URLSession(configuration: .default)
    var request = URLRequest(url: url)
    request.networkServiceType = priority == .high ? .responsiveData : .default
    let (data, _) = try await session.data(for: request)
    return data
  }
}

// MARK: Utility methods

private extension SwiftyImageCache {
  /// Checks if there is enough disk space to store the given data.
  /// - Parameter data: The image data to be cached.
  /// - Returns: `true` if there is sufficient space, otherwise `false`.
  func hasSufficientDiskSpace(for data: Data) throws -> Bool {
    let freeSpace = try getSpaceAmount()
    return freeSpace > Int64(data.count)
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
  
  /// Saves the image data to both memory and disk caches.
  /// - Parameters:
  ///   - url: The URL of the image.
  ///   - data: The image data.
  func saveToCache(url: URL, data: Data) {
    memoryCache.setObject(data as NSData, forKey: url as NSURL)
    let filePath = cacheDirectoryURL.appendingPathComponent(url.lastPathComponent)
    try? data.write(to: filePath)
  }
}

//
//  SwiftyImageCache.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 3/29/25.
//

import Foundation

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
    priority: LoadPriority
  ) async throws -> Data
}

/// Extension for FileManager to conform to ImageFileManaging protocol
extension FileManager: ImageFileManaging {}

/// An image caching object that stores images in both memory and disk.
actor SwiftyImageCache: SwiftyImageCaching {
  /// Shared instance of the image cache.
  static let shared = SwiftyImageCache()
  
  /// In-memory cache for quick access to frequently used images.
  private let memoryFetcher = SwiftyImageMemoryFetcher()
  /// Network Fetcher to load the image
  private let networkFetcher = SwiftyImageNetworkFetcher()
  
  /// Private initializer to enforce singleton usage.
  private init() { }

  /// Loads an image from cache or downloads it if not found.
  /// - Parameters:
  ///   - url: The URL of the image to load.
  ///   - priority: The priority for network fetching.
  /// - Returns: The image data.
  /// - Throws: `SwiftyImageCacheError` if loading fails.
  func loadImage(from url: URL, priority: LoadPriority = .standard) async throws -> Data {
    // Check memory cache
    if let cachedData = try memoryFetcher.imageData(forKey: url) {
      return cachedData
    } else {
      let imageData = try await networkFetcher.fetchRemoteImageData(from: url, with: priority)
      try memoryFetcher.setImageData(imageData, forKey: url)
      return imageData
    }
  }
}

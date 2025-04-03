//
//  SwiftyImageCacheError.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/1/25.
//

import Foundation

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

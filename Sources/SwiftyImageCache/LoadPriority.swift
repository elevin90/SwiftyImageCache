//
//  ImageLoadPriority.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 3/29/25.
//

import Foundation

/// Defines priority levels for loading images.
public enum LoadPriority: Int, Sendable {
  /// Low priority - suitable for background image loading.
  case low = 0
  /// Standard priority - the default priority for image loading.
  case standard = 1
  /// High priority - used for images that should be loaded immediately.
  case high = 2
}

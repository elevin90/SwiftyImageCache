//
//  SwiftyImageFetcher.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/2/25.
//

import Foundation

/// Extension for URLSession to conform to NetworkFetching protocol
extension URLSession: ImageDataFetching {}

/// Network image data fetch protocol
protocol ImageDataFetching {
  func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

actor SwiftyImageNetworkFetcher {
  private let session: ImageDataFetching
  
  init(session: ImageDataFetching = URLSession.shared) {
    self.session = session
  }
  
  /// Retrieves image data from remote
  /// - Returns: Image binary data
  func fetchRemoteImageData(from url: URL, with priority: LoadPriority) async throws -> Data {
    let session = URLSession(configuration: .default)
    var request = URLRequest(url: url)
    request.networkServiceType = priority == .high ? .responsiveData : .default
    let (data, _) = try await session.data(for: request)
    return data
  }
}

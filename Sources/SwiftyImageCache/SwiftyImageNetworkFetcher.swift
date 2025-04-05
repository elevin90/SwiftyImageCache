//
//  SwiftyImageFetcher.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/2/25.
//

import Foundation

/// Makes URLSession conform to ImageDataFetching protocol so it can be used for network image loading.
extension URLSession: ImageDataFetching {}

/// A protocol that abstracts image data fetching logic.
/// Allows for easier testing and dependency injection by mocking the network layer.
protocol ImageDataFetching: Sendable {
  /// Fetches data for the given URL request.
  /// - Parameters:
  ///   - request: The URL request to execute.
  ///   - delegate: An optional URL session task delegate.
  /// - Returns: A tuple containing the downloaded data and the response.
  func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

/// An actor responsible for asynchronously fetching remote image data over the network.
/// Uses dependency injection for testability and flexibility.
actor SwiftyImageNetworkFetcher {

  /// The object used to perform network requests. Default is `URLSession.shared`.
  private let session: ImageDataFetching

  /// Creates a new instance of the network fetcher with the provided session.
  /// - Parameter session: A custom or shared session conforming to `ImageDataFetching`.
  init(session: ImageDataFetching = URLSession.shared) {
    self.session = session
  }

  /// Downloads image data from the given URL, respecting the specified loading priority.
  ///
  /// - Parameters:
  ///   - url: The URL to fetch the image data from.
  ///   - priority: The desired loading priority for the request (e.g. `.high` for quick response).
  /// - Returns: The raw image data.
  func fetchRemoteImageData(from url: URL, with priority: LoadPriority) async throws -> Data {
    var request = URLRequest(url: url)
    
    // Adjust the network service type based on priority
    request.networkServiceType = priority == .high ? .responsiveData : .default
    
    // Perform the request and return the image data
    let (data, _) = try await session.data(for: request, delegate: nil)
    return data
  }
}

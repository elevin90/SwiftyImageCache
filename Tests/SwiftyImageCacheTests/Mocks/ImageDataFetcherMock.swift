//
//  ImageDataFetcherMock.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/4/25.
//

import Foundation
@testable import SwiftyImageCache

final class ImageDataFetcherMock: ImageDataFetching, @unchecked Sendable {
  var expectedData: Data
  var expectedResponse: URLResponse

  init(expectedData: Data, expectedResponse: URLResponse) {
    self.expectedData = expectedData
    self.expectedResponse = expectedResponse
  }

  func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
    return (expectedData, expectedResponse)
  }
}

//
//  SwiftyImageNetworkFetcherTests.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/4/25.
//

import XCTest
@testable import SwiftyImageCache

// Network fetcher tests
final class SwiftyImageNetworkFetcherTests: XCTestCase {

  // Test for remote image data fetch
  func testFetchRemoteImageDataReturnsExpectedData() async throws {
    // Given
    guard let expectedData = "mock image data".data(using: .utf8),
          let url = URL(string: "https://example.com/image.png") else {
      return
    }
    let mockResponse = HTTPURLResponse(
      url: URL(string: "https://example.com/image.png")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!
    
    let mockSession = ImageDataFetcherMock(expectedData: expectedData, expectedResponse: mockResponse)
    let fetcher = SwiftyImageNetworkFetcher(session: mockSession)
    let testURL = url
    
    // When
    let data = try await fetcher.fetchRemoteImageData(from: testURL, with: .standard)
    
    XCTAssertEqual(data, expectedData, "Fetched data should match expected mock data")
  }
}


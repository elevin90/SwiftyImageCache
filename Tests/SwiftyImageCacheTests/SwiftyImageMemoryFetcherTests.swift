//
//  SwiftyImageMemoryFetcherTests.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/3/25.
//

import XCTest
@testable import SwiftyImageCache

// Image Memory fetcher tests
final class SwiftyImageMemoryFetcherTests: XCTestCase {
  // An object which is responsible for fetching image data from cache or persistant storage if the image data can be found
  private var memoryFetcher: SwiftyImageMemoryFetcher?
  // Mocked file manager object
  private var mockFileManager: FileManagerMock?

  override func setUp() {
    super.setUp()
    mockFileManager = FileManagerMock()
    memoryFetcher = SwiftyImageMemoryFetcher(fileManager: mockFileManager ?? FileManagerMock())
  }

  override func tearDown() {
    memoryFetcher = nil
    mockFileManager = nil
    super.tearDown()
  }

  // Test for sufficient space calculation on the disk
  func testHasSufficientDiskSpace() throws {
    let data = Data(count: 5000)
    let hasSpace = try memoryFetcher?.hasSufficientDiskSpace(for: data) ?? false

    XCTAssertNotNil(memoryFetcher, "Memory fetcher should be initialized")
    XCTAssertTrue(hasSpace, "There should be sufficient space")
  }

  // Test for cache retrieves correct image data
  func testCacheStoresImageData() throws {
    let url = URL(string: "https://example.com/image.png")!
    let data = "test".data(using: .utf8)!

    try memoryFetcher?.setImageData(data, forKey: url)
    let cachedData = try memoryFetcher?.imageData(forKey: url)
  
    XCTAssertNotNil(cachedData, "The data should be in cache")
    XCTAssertEqual(cachedData, data, "Data from the cache doesn't match the original data")
  }

  // Error test
   func testMemoryCacheReturnsNilForMissingData() throws {
     let url = URL(string: "https://example.com/missing.png")!
     let cachedData = try memoryFetcher?.imageData(forKey: url)
     
     XCTAssertNil(cachedData, "In case there is no data in cache, the method should return nil")
   }
}

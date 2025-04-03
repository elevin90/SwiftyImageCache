import XCTest
@testable import SwiftyImageCache

final class SwiftyImageCacheTests: XCTestCase {
  final class URLSessionMock: ImageDataFetching {
    var data: Data?
    
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
      guard let data = data else {
        throw URLError(.badServerResponse)
      }
      return (data, URLResponse(url: request.url!, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil))
    }
  }
  
  final class ImageMemoryCacheMock {
    private(set) var cacheDictionary: [NSURL: NSData] = [:]
    
    func object(forKey key: NSURL) -> NSData? {
      cacheDictionary[key]
    }
    
    func setObject(_ obj: NSData, forKey key: NSURL) {
      cacheDictionary[key] = obj
    }
  }
  
  final class MockFileManager: ImageFileManaging {
      var shouldReturnData = false
      var mockData: Data?
      var mockFreeSpace: Int64 = 0
      
      func fileExists(atPath path: String) -> Bool {
          return shouldReturnData
      }
      
      func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws {}
      
      func attributesOfFileSystem(forPath path: String) throws -> [FileAttributeKey : Any] {
          return [.systemFreeSize: mockFreeSpace]
      }
      
      func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
          return [URL(fileURLWithPath: "/mock/path")]
      }
  }

  var cache: SwiftyImageCache!
  var mockNetworkFetcher: URLSessionMock!
  var mockFileManager: MockFileManager!
  private let testURL = URL(string: "https://example.com/test-image.jpg")!
  private let testData = "TestImageData".data(using: .utf8)!
  
  override func setUpWithError() throws {
          super.setUp()
          // Инициализация моков и объекта кэша
          mockNetworkFetcher = URLSessionMock()
          mockFileManager = MockFileManager()
       //   cache = SwiftyImageCache(networkFetcher: mockNetworkFetcher, fileManager: mockFileManager)
      }
      
      override func tearDownWithError() throws {
          cache = nil
          mockNetworkFetcher = nil
          mockFileManager = nil
          super.tearDown()
      }
      
      // MARK: - Test Memory Cache
//      
//      func testFetchFromCache_whenDataIsCached_returnsCachedData() async throws {
//          let url = URL(string: "https://example.com/image.jpg")!
//          let expectedData = Data([0x01, 0x02, 0x03])
//          
//          // Мокаем кэш
//        await cache.loadImage(from: <#T##URL#>)
//        memoryCache.setObject(expectedData as NSData, forKey: url as NSURL)
//          
//          let fetchedData = cache.fetchFromCache(from: url)
//          
//          XCTAssertEqual(fetchedData, expectedData, "Fetched data should match cached data")
//      }
//  
  
}

//
//  File.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/4/25.
//

import Foundation
@testable import SwiftyImageCache

// File manager mocked object
final class FileManagerMock {
  var existingFiles: Set<String> = []
  var fileAttributes: [FileAttributeKey: Any] = [.systemFreeSize: Int64.max]
  var savedFiles: [String: Data] = [:]
}

// Conformance to ImageFileManaging protocol
extension FileManagerMock: ImageFileManaging {
  func fileExists(atPath path: String) -> Bool {
    existingFiles.contains(path)
  }
  
  func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws {
    existingFiles.insert(url.path)
  }
  
  func attributesOfFileSystem(forPath path: String) throws -> [FileAttributeKey : Any] {
    fileAttributes
  }
  
  func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
    [URL(fileURLWithPath: "/mock/cache")]
  }
}


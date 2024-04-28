//
//  FileManager+Utils.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (19.01.2022).

import Foundation

// MARK: - FileAttributeLoader
extension FileManager: FileAttributeLoader {
    func fileAttributes(atUrl url: URL) -> [FileAttributeKey: Any]? {
        try? attributesOfItem(atPath: url.path)
    }
}

// MARK: - FileStorage
extension FileManager: LoggerFileStorage {
    func createFile(atPath path: String) {
        createFile(atPath: path, contents: nil)
    }
    
    func deleteFile(atPath path: String) {
        try? removeItem(atPath: path)
    }
    
    func filesNames(atPath path: String) -> [String] {
        (try? contentsOfDirectory(atPath: path)) ?? []
    }
    
    func contents(ofFileAtPath path: String, encoding: String.Encoding) -> String? {
        guard let data = contents(atPath: path) else { return nil }
        return String(data: data, encoding: encoding)
    }
    
    func files(inDirectory path: String) -> [String] {
        if let content = try? contentsOfDirectory(atPath: path) {
            return content
        }
        return [String]()
    }
    
    func createLogsFolder(atPath path: String) {
        try? createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
}

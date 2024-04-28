//
//  Meta.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (13.01.2022).

import Foundation

public struct FileMetaImpl: FileMeta {
    private var fileAttributes: [FileAttributeKey: Any]
    
    let url: URL
    let creationDate: Date

    var fileSize: UInt {
        fileAttributes[.size] as? UInt ?? 0
    }
    
    init(url: URL, loader: FileAttributeLoader, config: LoggerConfig) throws {
        self.url = url
        self.fileAttributes = loader.fileAttributes(atUrl: url) ?? [:]
        self.creationDate = try FileMetaImpl.convertToDate(fileName: url.lastPathComponent, config: config)
    }
}

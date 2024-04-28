//
//  LogFileImpl.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (21.01.2022).

import Foundation

final class LogFileImpl: FileMeta {    
    private let fileHandle: FileHandle
    private let config: LoggerConfig
    
    let url: URL
    let creationDate: Date
    
    var fileSize: UInt {
        fileHandle.seekToEndOfFile()
        return (try? UInt(fileHandle.offset())) ?? 0
    }
    
    var fileName: String {
        url.lastPathComponent
    }
    
    init(forAction action: Action, fileUrl: URL, config: LoggerConfig) throws {
        self.creationDate = try FileMetaImpl.convertToDate(fileName: fileUrl.lastPathComponent, config: config)
        self.url = fileUrl
        self.config = config
        
        if action == .write {
            self.fileHandle = try FileHandle(forWritingTo: fileUrl)
        } else {
            self.fileHandle = try FileHandle(forReadingFrom: fileUrl)
        }
    }
    
    func write(_ log: String) throws {
        guard !log.isEmpty else { return }
        
        fileHandle.seekToEndOfFile()
        try fileHandle.write(contentsOf: convertToData(log))
    }
    
    func read(offset: UInt) throws -> Data? {
        try fileHandle.seek(toOffset: UInt64(offset))
        return try fileHandle.readToEnd()
    }
    
    // MARK: - Private
    private func convertToData(_ log: String) -> Data {
        Data(log.utf8)
    }
    
    enum Action {
        case write, read
    }
}

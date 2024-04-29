//
//  LoggerStorageSpy.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (28.01.2022).
//

import Foundation
@testable import K_Logger

final class LoggerStorageSpy: SyncExecutable {
    var lock = DispatchSemaphore(value: 1)
    
    private let storage: LoggerStorage
    
    init(loggerStorage: LoggerStorage) {
        self.storage = loggerStorage
    }
    
    // MARK: - Tests
    private(set) var logSizesRequests = [String]()
    private(set) var metaForAllFilesRequests = [[FileMeta]]()
    private(set) var fileNamesFromCreateRequests = [String]()
    private(set) var logsFromSaveRequest = [String]()
    private(set) var filesFromSaveRequest = [FileMeta]()
    private(set) var filesFromDeleteRequest = [FileMeta]()
    private(set) var createFileRequestDate = Date()
    private(set) var dropFileRequestDate = Date()
    private(set) var fileMetasFromLogsRequest = [FileMeta]()
    private(set) var offsetFromLogRequest = [UInt]()

    private var testMeta = [FileMeta]()
    
    func setTestMeta(_ meta: [FileMeta]) {
        testMeta = meta
    }
}

// MARK: - LoggerStorage
extension LoggerStorageSpy: LoggerStorage {
    func metaForAllFiles() -> [FileMeta] {
        var result = [FileMeta]()
        
        sync {
            result = storage.metaForAllFiles()
            metaForAllFilesRequests.append(result)
        }
        
        return testMeta.isEmpty ? result : testMeta
    }
    
    func log(fromFile file: FileMeta, offset: UInt) -> String {
        var result = ""
        
        sync {
            fileMetasFromLogsRequest.append(file)
            offsetFromLogRequest.append(offset)
            
            result = storage.log(fromFile: file, offset: offset)
        }
        
        return result
    }
    
    func saveLog(_ log: String, to file: FileMeta) {
        sync {
            logsFromSaveRequest.append(log)
            filesFromSaveRequest.append(file)
            
            storage.saveLog(log, to: file)
        }
    }
    
    func deleteFile(_ file: FileMeta) {
        sync {
            filesFromDeleteRequest.append(file)
            storage.deleteFile(file)
            dropFileRequestDate = Date()
        }
    }
        
    func createFile(withName fileName: String) throws -> FileMeta {
        var result: FileMeta

        lock.wait()
        fileNamesFromCreateRequests.append(fileName)
        result = try storage.createFile(withName: fileName) as FileMeta
        createFileRequestDate = Date()
        lock.signal()
        
        return result
    }
    
    func logSize(_ log: String) -> UInt {
        logSizesRequests.append(log)
        return storage.logSize(log)
    }
    
    func currentFileMeta() -> FileMeta? {
        var result: FileMeta?

        sync {
            result = storage.currentFileMeta()
        }
        
        return result
    }
    
    func readerFor(file: FileMeta) -> LineReader? {
        LineReaderImpl(path: file.url.path)
    }
    
    func logFiles() -> [LogFile] {
        var result = [LogFile]()

        sync {
            result = storage.logFiles()
        }
        
        return result
    }
}

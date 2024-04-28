//
//  FileActionProviderSpy.swift
//  LoggerTests
//
//  Created by Volodymyr Kotsiubenko (28.01.2022).
//

import Foundation
@testable import K_Logger

final class FileActionProviderSpy: SyncExecutable {
    var lock = DispatchSemaphore(value: 1)
    
    var maxFilesCount: UInt = 0
    var maxFilesSize: UInt = 0
    
    private let provider: FileActionProvider
    
    init(loggerFileActionProvider: FileActionProvider) {
        self.provider = loggerFileActionProvider
    }
    
    // MARK: - Tests
    private(set) var actionForLogCallsCount = 0
    private(set) var recordSize: UInt?
    private(set) var fileMetas: [FileMeta]?
    private(set) var newFileName: String?
    private(set) var fileForWrite: FileMeta?
    private(set) var fileForDelete: FileMeta?
}

// MARK: - FileActionProvider
extension FileActionProviderSpy: FileActionProvider {
    func actionForLog(ofSize recordSize: UInt, using fileMetas: [FileMeta]) -> FileAction {
        var result: FileAction = .skip

        sync {
            actionForLogCallsCount += 1
            self.recordSize = recordSize
            self.fileMetas = fileMetas
            
            result = provider.actionForLog(ofSize: recordSize, using: fileMetas)
            
            switch result {
            case .create(let fileName):
                newFileName = fileName
            case .write(let file):
                fileForWrite = file
            case .rotation(let dropFile, let newFileName):
                fileForDelete = dropFile
                self.newFileName = newFileName
            case .skip:
                break
            }
        }
        
        return result
    }
}

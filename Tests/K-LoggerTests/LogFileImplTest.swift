//
//  LogFileImplTest.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (21.01.2022).
//

import XCTest
@testable import K_Logger

final class LogFileImplTest: FileMetaTests {
    func test_fileSize_ensureReturnedFileSizeCorrect_AfterInitialization() throws {
        try super.test_fileSize_ensureReturnedSizeIsCorrect()
    }
    
    func test_fileName_ensureReturnedFileNameCorrect_AfterInitialization() throws {
        try super.test_fileName_ensureReturnedFileNameIsCorrect()
    }

    func test_creationDate_ensureReturnedCreationDateCorrect_AfterInitialization() throws {
        try super.test_creationDate_ensureReturnedCreationDateIsCorrect()
    }
}

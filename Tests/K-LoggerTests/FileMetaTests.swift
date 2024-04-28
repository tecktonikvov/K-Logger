//
//  FileMetaTests.swift
//  LoggerTests
//
//  Created by Volodymyr Kotsiubenko (24.01.2022).
//

import XCTest
import Foundation

@testable import K_Logger

class FileMetaTests: BaseLogFileTest {
    func test_fileSize_ensureReturnedSizeIsCorrect() throws {
        let sut = try fileMeta(size: 25)

        XCTAssertEqual(sut.fileSize, 25)
    }
    
    func test_creationDate_ensureReturnedCreationDateIsCorrect() throws {
        let creationDate: Date = twoDaysBefore
        let sut = try fileMeta(creationDate: creationDate)

        XCTAssertEqual(formatter.string(from: sut.creationDate), formatter.string(from: creationDate))
    }
    
    func test_fileName_ensureReturnedFileNameIsCorrect() throws {
        let creationDate: Date = twoDaysBefore
        let sut = try fileMeta(creationDate: creationDate)
        
        XCTAssertEqual(sut.fileName, fileNameByDate(creationDate))
    }
    
    func test_creationDate_errorThrowsIfFileNameDoesNotMatchSpecifiedFormat() {
        XCTAssertThrowsError(try LogFileImpl(forAction: .read,
                                             fileUrl: fileUrlWitIncorrectFileName,
                                             config: testConfig))
    }
    
    func test_creationDate_correctErrorThrowsIfFileNameDoesNotMatchSpecifiedFormat() {
        var thrownError: Error?

        XCTAssertThrowsError(try LogFileImpl(forAction: .read,
                                             fileUrl: fileUrlWitIncorrectFileName,
                                             config: testConfig)) {
            thrownError = $0
        }
        XCTAssertEqual(thrownError as? LogFileError, .invalidFileName)
    }
    
    // MARK: - Helpers
    private lazy var fileUrlWitIncorrectFileName = URL(fileURLWithPath: testConfig.fullFileName(fromFileName: "incorrectName") + testConfig.fileExtension)
}

//
//  LogExtractorImplTests.swift
//
//  Created by Volodymyr Kotsiubenko (03.02.2022).
//

import XCTest
@testable import K_Logger

final class LogExtractorImplTests: BaseLoggerTests {
    func test_extractContent_ensureResultIsEmpty_ifNoLogFilesExist() {
        let sut = makeSUT()
        
        let result = sut.extractor.extractContent(from: twoDaysBefore, to: currentDate)
        XCTAssertEqual(result, "")
    }
    
    func test_extractContent_ensureResultIsEmpty_ifExistentFilesNotInDateRange() throws {
        try createTestFile()
        let sut = makeSUT()

        let result = sut.extractor.extractContent(from: twoDaysBefore, to: dayBefore)
        XCTAssertEqual(result, "")
    }
    
    func test_extractContent_ensureResultIsEmpty_ifFileInRangeAndEmpty() throws {
        try createTestFile(content: "")
        let sut = makeSUT()

        let result = sut.extractor.extractContent(from: dayBefore, to: Date())
        XCTAssertEqual(result, "")
    }
    
    func test_extractContent_ensureResultCorrect_ifOneFileExists_AndAllDataInRange() throws {
        let data = validLogStringByCurrentDate()
        try createTestFile(content: data)
        let sut = makeSUT()

        let result = sut.extractor.extractContent(from: dayBefore, to: Date())
        XCTAssertEqual(result, data)
    }
 
    func test_extractContent_ensureResultCorrect_ifOneFileExists_AndFirstPartOfDataInRange() throws {
        let testDataToWrite1 = validLogStringByCurrentDate() + "some string1"
        wait()
        let testDataToWrite2 = validLogStringByCurrentDate() + "some string2"
        wait()
        
        let testFile = try createTestFile(content: testDataToWrite1 + "\n")
        writeTo(fileUrl: testFile.url, data: testDataToWrite2)
        wait()
        
        let toDate = Date()
        wait()
        
        let anyValidData = validLogStringByCurrentDate()
        writeTo(fileUrl: testFile.url, data: anyValidData)
        
        let sut = makeSUT()
        let expect = testDataToWrite1 + "\n" + testDataToWrite2
        let result = sut.extractor.extractContent(from: dayBefore, to: toDate)
        
        XCTAssertEqual(result, expect)
    }
    
    func test_extractContent_ensureResultCorrect_ifOneFileExists_AndLastPartOfDataInRange() throws {
        let testFile = try createTestFileWithHeaders()
        writeTo(fileUrl: testFile.url, data: validLogStringByCurrentDate())
        wait()
        
        let fromDate = Date()
        wait()
        
        let testDataToWrite1 = validLogStringByCurrentDate() + "some string1"
        wait()
        let testDataToWrite2 = validLogStringByCurrentDate() + "some string2"
        wait()
        
        writeTo(fileUrl: testFile.url, data: testDataToWrite1)
        writeTo(fileUrl: testFile.url, data: testDataToWrite2)
        
        let sut = makeSUT()
        let expect = testDataToWrite1 + "\n" + testDataToWrite2
        let result = sut.extractor.extractContent(from: fromDate, to: Date())
        
        XCTAssertEqual(result, expect)
    }
    
    func test_extractContent_ensureResultCorrect_ifOneFileExists_AndMiddlePartOfDataInRange() throws {
        let testFile = try createTestFileWithHeaders()

        writeTo(fileUrl: testFile.url, data: validLogStringByCurrentDate())
        writeTo(fileUrl: testFile.url, data: validLogStringByCurrentDate())
        wait()
        
        let fromDate = Date()
        wait()
        
        let testDataToWrite1 = validLogStringByCurrentDate() + "some string1"
        wait()
        let testDataToWrite2 = validLogStringByCurrentDate() + "some string2"
        wait()
        
        writeTo(fileUrl: testFile.url, data: testDataToWrite1)
        writeTo(fileUrl: testFile.url, data: testDataToWrite2)
        
        let sut = makeSUT()
        let expect = testDataToWrite1 + "\n" + testDataToWrite2
        let result = sut.extractor.extractContent(from: fromDate, to: Date())
        
        XCTAssertEqual(result, expect)
    }
    
    func test_extractContent_ensureResultCorrect_ifFewFilesInRange_AndFirstFileMustBeReadPartly() throws {
        let testFile1 = try createTestFileWithHeaders()
        writeTo(fileUrl: testFile1.url, data: validLogStringByCurrentDate())
        wait()

        let fromDate = Date()
        wait()

        let testDataToWrite1 = validLogStringByCurrentDate() + "some string1"
        writeTo(fileUrl: testFile1.url, data: testDataToWrite1)
        wait()

        let testFile2 = try createTestFileWithHeaders()
        wait()

        let testDataToWrite2 = validLogStringByCurrentDate() + "some string2"
        writeTo(fileUrl: testFile2.url, data: testDataToWrite2)
        wait()

        let sut = makeSUT()
        let expect = testDataToWrite1 + "\n" + testDataToWrite2
        let result = sut.extractor.extractContent(from: fromDate, to: Date())

        XCTAssertEqual(result, expect)
    }

    func test_extractContent_ensureResultCorrect_ifFewFilesInRange_AndLastFileMustBeReadPartly() throws {
        let testFile1 = try createTestFileWithHeaders()
        writeTo(fileUrl: testFile1.url, data: validLogStringByCurrentDate())
        wait()

        let fromDate = Date()
        wait()

        let testDataToWrite1 = validLogStringByCurrentDate() + "some string1"
        writeTo(fileUrl: testFile1.url, data: testDataToWrite1)
        wait()

        let testFile2 = try createTestFileWithHeaders()
        wait()

        let testDataToWrite2 = validLogStringByCurrentDate() + "some string2"
        writeTo(fileUrl: testFile2.url, data: testDataToWrite2)
        wait()

        let toDate = Date()
        wait()

        writeTo(fileUrl: testFile2.url, data: validLogStringByCurrentDate())

        let sut = makeSUT()
        let expect = testDataToWrite1 + "\n" + testDataToWrite2
        let result = sut.extractor.extractContent(from: fromDate, to: toDate)

        XCTAssertEqual(result, expect)
    }

    func test_extractContent_ensureResultCorrect_ifFewFilesInRange_AndAllDataInRange() throws {
        let fromDate = Date()
        wait()

        let testFile1 = try createTestFileWithHeaders()
        wait()

        let testDataForFirstFile = validLogStringByCurrentDate() + "some string1"
        writeTo(fileUrl: testFile1.url, data: testDataForFirstFile)
        wait()

        let testDataForSecondFile = validLogStringByCurrentDate() + "some string2"
        wait()

        let testFile2 = try createTestFileWithHeaders()
        wait()

        writeTo(fileUrl: testFile2.url, data: testDataForSecondFile)

        let sut = makeSUT()
        let expect = testDataForFirstFile + "\n" + testDataForSecondFile
        let result = sut.extractor.extractContent(from: fromDate, to: Date())
        
        XCTAssertEqual(result, expect)
    }

    func test_extractContent_ensureResultContainsLogsFromNewFiles() throws {
        let testLog = validLogStringByCurrentDate()
        let sut = makeSUT()

        try createTestFile(content: anyValidHeaders + testLog)

        let result = sut.extractor.extractContent(from: dayBefore, to: Date())

        XCTAssert(result.contains(testLog))
    }
        
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        let logsFormatterSpy = LogFormatterSpy(logFormatter: LogFormatterImpl(config: testConfig))
        let storageSpy = LoggerStorageSpy(loggerStorage: LoggerStorageImpl(fileManager: fileManager,
                                                                           fileAttributeLoader: fileManager,
                                                                           config: testConfig))
        let extractor = LogExtractorImpl(storage: storageSpy, formatter: logsFormatterSpy)
        
        trackForMemoryLeaks(logsFormatterSpy, file: file, line: line)
        trackForMemoryLeaks(storageSpy, file: file, line: line)
        trackForMemoryLeaks(extractor, file: file, line: line)

        return SUT(extractor: extractor, logFormatter: logsFormatterSpy, storageSpy: storageSpy)
    }
    
    private struct SUT {
        let extractor: LogExtractor
        let logFormatter: LogFormatterSpy
        let storageSpy: LoggerStorageSpy
    }  
    
    private func writeTo(fileUrl url: URL, data: String) {
        guard let fileHandle = try? FileHandle(forWritingTo: url) else { return }
        
        _ = try? fileHandle.seekToEnd()
        let lewLineWithData = data + "\n"
        try? fileHandle.write(contentsOf: Data(lewLineWithData.utf8))
    }
        
    private func createTestFileWithHeaders() throws -> FileMeta {
        try createTestFile(content: anyValidHeaders)
    }
}

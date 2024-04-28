//
//  LoggerManagerTests.swift
//  StorageTests
//
//  Created by Volodymyr Kotsiubenko (27.01.2022).
//

import XCTest
@testable import K_Logger

final class LoggerManagerTests: BaseLoggerTests {
    // MARK: - saveLog method test
    func test_saveLog_ensureLogForSizeIsSameAsInput() {
        let sut = makeSUT()
        let testLog = "test log"
        
        sut.manager.saveLog(testLog)
        XCTAssertEqual(sut.storageSpy.logSizesRequests.first, testLog)
    }
    
    func test_saveLog_ensureLogSizeCalledOnce() {
        let sut = makeSUT()
        
        sut.manager.saveLog(anyString)
        XCTAssertEqual(sut.storageSpy.logSizesRequests.count, 1)
    }
    
    func test_saveLog_ensureActionForLogCalledWithSameRecordSizeAsInput() {
        let sut = makeSUT()
        let testLog = "test log"
        let testLogSize = UInt(testLog.lengthOfBytes(using: .utf8))

        sut.manager.saveLog(testLog)
        XCTAssertEqual(sut.providerSpy.recordSize, testLogSize)
    }
    
    func test_saveLog_ensureActionForLogCallContainsSameMetaFilesAsReturned_ifNoFilesExist() {
        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        XCTAssertEqual(sut.providerSpy.fileMetas as? [FileMetaImpl],
                       sut.storageSpy.metaForAllFilesRequests.first as? [FileMetaImpl])
    }
    
    func test_saveLog_ensureActionForLogCallContainsSameMetaFilesAsReturned_ifAnyFilesExist() throws {
        try createTestFile()
        try createTestFile()

        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        XCTAssertEqual(sut.providerSpy.fileMetas as? [FileMetaImpl],
                       sut.storageSpy.metaForAllFilesRequests.first as? [FileMetaImpl])
    }
    
    func test_saveLog_ensureActionForLogCalledOnce() {
        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        XCTAssertEqual(sut.providerSpy.actionForLogCallsCount, 1)
    }
    
    func test_saveLog_ensureCreateCalled_whenReturnedCreateAction() {
        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        XCTAssert(!sut.storageSpy.fileNamesFromCreateRequests.isEmpty)
    }
    
    func test_saveLog_ensureCreateCalled_withSameFileNameAsReturnedInCreateAction() {
        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        XCTAssertEqual(sut.storageSpy.fileNamesFromCreateRequests.first, sut.providerSpy.newFileName)
    }
    
    func test_saveLog_ensureCreateCalledOnce_whenReturnedCreateAction() {
        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        XCTAssertEqual(sut.storageSpy.fileNamesFromCreateRequests.count, 1)
    }
    
    func test_saveLog_ensureSaveLogCalled_whenReturnedSaveAction() {
        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        XCTAssert(!sut.storageSpy.logsFromSaveRequest.isEmpty)
        XCTAssert(!sut.storageSpy.filesFromSaveRequest.isEmpty)
    }
    
    func test_saveLog_ensureSaveLogCalled_withCorrectNewFileIfItNonExitingBefore() {
        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        let createdFileName = (sut.storageSpy.fileNamesFromCreateRequests.first ?? "")
        
        XCTAssertEqual(createdFileName, sut.storageSpy.filesFromSaveRequest.first?.fileName)
    }
    
    func test_saveLog_ensureSaveLogCalled_withSameMetaAsReturnedInSaveAction() throws {
        try createTestFileWithHeaders()
        
        let sut = makeSUT()

        sut.manager.saveLog(anyString)
        XCTAssertEqual(sut.providerSpy.fileForWrite as? FileMetaImpl,
                       sut.storageSpy.filesFromSaveRequest.first as? FileMetaImpl)
    }
    
    func test_saveLog_ensureSaveLogCalled_withSameLogAsInput() {
        let sut = makeSUT()
        let testString = "test string"
        
        sut.manager.saveLog(testString)
        XCTAssertEqual(sut.storageSpy.logsFromSaveRequest.last, testString + "\n")
    }
    
    func test_saveLog_ensureSaveLogCalledOnce_whenReturnedSaveAction() throws {
        try createTestFile()

        let sut = makeSUT()

        sut.manager.saveLog("any")
        XCTAssertEqual(sut.storageSpy.filesFromSaveRequest.count, 1)
    }
    
    func test_saveLog_ensureDeleteCalled_whenReturnedRotationAction() throws {
        try createTestFile(content: "more than ten bytes string")
        
        let sut = makeSUT(maxFilesCount: 1, maxFilesSize: 10)
        sut.manager.saveLog(lessThanTenBynesString)
        
        XCTAssert(!sut.storageSpy.filesFromDeleteRequest.isEmpty)
    }
    
    func test_saveLog_ensureDeleteCalled_withSameMetaAsReturnedInRotationAction() throws {
        try createTestFile(content: "more than ten bytes string")

        let sut = makeSUT(maxFilesCount: 1, maxFilesSize: 10)
        sut.manager.saveLog(lessThanTenBynesString)
        
        XCTAssert(!sut.storageSpy.filesFromDeleteRequest.isEmpty)
        XCTAssertEqual(sut.providerSpy.fileForDelete as? FileMetaImpl,
                       sut.storageSpy.filesFromDeleteRequest.first as? FileMetaImpl)
    }
    
    func test_saveLog_ensureDeleteCalledOnce_whenReturnedRotationAction() throws {
        try createTestFile(content: "more than ten bytes string")
        
        let sut = makeSUT(maxFilesCount: 1, maxFilesSize: 10)
        sut.manager.saveLog(lessThanTenBynesString)
        
        XCTAssertEqual(sut.storageSpy.filesFromDeleteRequest.count, 1)
    }
    
    func test_saveLog_ensureCreateCalled_whenReturnedRotationAction() throws {
        try createTestFile(content: "more than ten bytes string")
        
        let sut = makeSUT(maxFilesCount: 1, maxFilesSize: 10)
        sut.manager.saveLog(lessThanTenBynesString)
        
        XCTAssert(!sut.storageSpy.fileNamesFromCreateRequests.isEmpty)
    }
    
    func test_saveLog_ensureCreateCalled_withSameNewFileNameAsReturnedInRotationAction() throws {
        try createTestFile(content: "more than ten bytes string")

        let sut = makeSUT(maxFilesCount: 1, maxFilesSize: 10)
        sut.manager.saveLog(lessThanTenBynesString)
        
        XCTAssertFalse(sut.storageSpy.filesFromDeleteRequest.isEmpty)
        XCTAssertEqual(sut.providerSpy.newFileName, sut.storageSpy.fileNamesFromCreateRequests.first)
    }
    
    func test_saveLog_ensureMethodsCalledInRightOrder_whenReturnedRotationAction() throws {
        try createTestFile(content: "more than ten bytes string")

        let sut = makeSUT(maxFilesCount: 1, maxFilesSize: 10)
        sut.manager.saveLog(lessThanTenBynesString)
        
        XCTAssertTrue(sut.storageSpy.createFileRequestDate > sut.storageSpy.dropFileRequestDate)
    }
    
    func test_saveLog_ensureCreateCalledOnce_whenReturnedRotationAction() throws {
        try createTestFile(content: "more than ten bytes string")

        let sut = makeSUT(maxFilesCount: 1, maxFilesSize: 10)
        sut.manager.saveLog(lessThanTenBynesString)
        
        XCTAssertEqual(sut.storageSpy.fileNamesFromCreateRequests.count, 1)
    }
    
    func test_saveLog_ensureNewFileContainsHeaders() {
        let sut = makeSUT()
        
        sut.manager.saveLog("")
        XCTAssertEqual(contentOfLastCreatedFile().first, "#")
    }
    
    func test_saveLog_ensureNewFileContainsEmptyStringAfterHeaders() {
        let sut = makeSUT()
        
        sut.manager.saveLog("")
        let lastLine = contentOfLastCreatedFile().components(separatedBy: "\n").last
        XCTAssertEqual(lastLine, "")
    }
    
    func test_saveLog_ensureLogSavedCorrectly_whenNewFileWasCreated() {
        let testLogString = "test log string"
        let sut = makeSUT()
        
        sut.manager.saveLog(testLogString)
        
        let expect = contentOfLastCreatedFileWithoutHeaders()
        XCTAssertEqual(testLogString + "\n", expect)
    }
     
    // MARK: - logs method test
    func test_logs_ensureFilesRequested() {
        let sut = makeSUT()
        _ = sut.manager.logs(from: anyDateBefore, to: currentDate)
        XCTAssertFalse(sut.extractor.datesFormExtractContentRequest.isEmpty)
    }

    func test_logs_ensureFilesRequestedOnce() {
        let sut = makeSUT()

        _ = sut.manager.logs(from: anyDateBefore, to: currentDate)
        XCTAssertEqual(sut.extractor.datesFormExtractContentRequest.count, 1)
    }
    
    func test_logs_ensureDatesCorrectInLogCall() {
        let sut = makeSUT()
        let testEndDate = currentDate

        _ = sut.manager.logs(from: anyDateBefore, to: testEndDate)
        XCTAssertEqual(sut.extractor.datesFormExtractContentRequest[anyDateBefore], testEndDate)
    }
    
    func test_logs_ensureResultIsSameAsExtractorReturn() throws {
        let testContent = validLogStringByCurrentDate()
        try createTestFile(content: anyValidHeaders + testContent)
        
        let sut = makeSUT()
        
        let result = sut.manager.logs(from: anyDateBefore, to: currentDate)
        let expect = sut.extractor.returnedResult
        XCTAssertEqual(result, expect)
    }

    // MARK: - Helpers
    private let lessThanTenBynesString = "string"
   
    private struct SUT {
        let manager: LoggerManager
        let providerSpy: FileActionProviderSpy
        let storageSpy: LoggerStorageSpy
        let extractor: LogExtractorSpy
    }
    
    private func makeSUT(maxFilesCount: UInt = 10, maxFilesSize: UInt = 500,
                         file: StaticString = #filePath, line: UInt = #line) -> SUT {
        let providerSpy = FileActionProviderSpy(
            loggerFileActionProvider: FileActionProviderImpl(config: testConfig,
                                                                   maxFilesCount: maxFilesCount,
                                                                   maxFilesSize: maxFilesSize))
        let storageSpy = LoggerStorageSpy(loggerStorage: LoggerStorageImpl(fileManager: fileManager,
                                                                           fileAttributeLoader: fileManager,
                                                                           config: testConfig))
        let extractorSpy = LogExtractorSpy(extractor: LogExtractorImpl(storage: storageSpy,
                                                                       formatter: LogFormatterImpl(config: testConfig)))
        
        let headersFormatter = LogHeadersFormatterImpl(config: testConfig)
        
        let manager = LoggerManager(actionProvider: providerSpy,
                                    storage: storageSpy,
                                    headersFormatter: headersFormatter,
                                    logsExtractor: extractorSpy,
                                    config: testConfig)
        
        trackForMemoryLeaks(providerSpy, file: file, line: line)
        trackForMemoryLeaks(storageSpy, file: file, line: line)
        trackForMemoryLeaks(manager, file: file, line: line)
        trackForMemoryLeaks(headersFormatter, file: file, line: line)
        trackForMemoryLeaks(extractorSpy, file: file, line: line)
        
        return SUT(manager: manager,
                   providerSpy: providerSpy,
                   storageSpy: storageSpy,
                   extractor: extractorSpy)
    }
    
    private func createTestFileWithHeaders() throws {
        try createTestFile(content: anyValidHeaders)
    }
}

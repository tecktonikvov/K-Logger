//
//  LoggerImplTests.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (10.02.2022).
//

import XCTest
import Foundation

@testable import K_Logger

extension LogFile: Equatable {
    public static func == (lhs: LogFile, rhs: LogFile) -> Bool {
        lhs.fileUrl == rhs.fileUrl
    }
}

extension LogFile: Comparable {
    public static func < (lhs: LogFile, rhs: LogFile) -> Bool {
        lhs.fileUrl.lastPathComponent < rhs.fileUrl.lastPathComponent
    }
}

final class LoggerImplTests: BaseLoggerTests {
    // MARK: - log method test
    func test_log_recordPerformedInBackgroundThread() {
        var completedThread: Thread?
        let expectation = expectation(description: "Completed thread must be background")
        let sut = makeSUT()
        
        sut.logSaver.logCompletion = {
            completedThread = Thread.current
            expectation.fulfill()
        }
        
        sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
      
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(completedThread)
        XCTAssert(completedThread != Thread.main)
    }
    
    // MARK: - logs method test
    func test_logs_readPerformedInBackgroundThread() {
        var completedThread: Thread?
        let expectation = expectation(description: "Completed thread must be background")
        let sut = makeSUT()
        
        sut.logRetriever.logsCompletion = {
            completedThread = Thread.current
            expectation.fulfill()
        }
        
        _ = sut.logger.logs(from: anyDateBefore, to: currentDate)
       
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(completedThread)
        XCTAssert(completedThread != Thread.main)
    }
    
    func test_logs_resultNotEmpty() throws {
        try createTestFile(content: validLogStringByCurrentDate())
        let sut = makeSUT()

        let result = sut.logger.logs(from: anyDateBefore, to: Date())
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - logFiles method test
    func test_logFiles_resultEmptyIfNoFilesExists() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.logger.logFiles().isEmpty)
    }
    
    func test_logFiles_resultNotEmptyIfAnyFilesExist() throws {
        let sut = makeSUT()
        
        try createTestFile()
        XCTAssertFalse(sut.logger.logFiles().isEmpty)
    }
    
    func test_logFiles_resultIsCorrect() throws {
        let sut = makeSUT()
        
        let files = try createTestFiles(number: 2)
        
        let result = sut.logger.logFiles().sorted()
        let expect = files.map { LogFile(fileUrl: $0.url) }.sorted()
        
        XCTAssertEqual(result, expect)
    }
    
    func test_logFiles_onlyOneFileExtensionSuffix() throws {
        let sut = makeSUT()

        try createTestFile()

        let result = sut.logger.logFiles().first?.fileUrl.lastPathComponent ?? ""

        XCTAssertTrue(result.hasSuffix(testConfig.fileExtension))
        XCTAssertFalse(result.hasSuffix(testConfig.fileExtension + testConfig.fileExtension))
    }

    // MARK: - Concurrent tests
    func test_saveOperationIsFinishedBeforeReadIsStarted() {
        let sut = makeSUT()
        var result = [XCTestExpectation]()

        let exp1 = expectation(description: "Save data #1")
        let exp2 = expectation(description: "Read data #2")

        sut.logSaver.logCompletion = {
            Thread.sleep(forTimeInterval: 0.05)
            result.append(exp1)
            exp1.fulfill()
        }
        sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
        
        sut.logRetriever.logsCompletion = {
            Thread.sleep(forTimeInterval: 0.025)
            
            XCTAssert(result.contains(exp1),
                      "Save data operation must be finished before the read is started")
            
            result.append(exp2)
            exp2.fulfill()
        }
        _ = sut.logger.logs(from: anyDateBefore, to: currentDate)
        
        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(result, [exp1, exp2])
    }
    
    func test_readOperationIsFinishedBeforeSaveIsStarted() {
        let sut = makeSUT()
        var result = [XCTestExpectation]()
        
        let exp1 = expectation(description: "Read data #1")
        let exp2 = expectation(description: "Save data #2")

        sut.logRetriever.logsCompletion = {
            Thread.sleep(forTimeInterval: 0.025)
            result.append(exp1)
            exp1.fulfill()
        }
        _ = sut.logger.logs(from: anyDateBefore, to: currentDate)
        
        sut.logSaver.logCompletion = {
            Thread.sleep(forTimeInterval: 0.05)
            XCTAssert(result.contains(exp1),
                      "Read data operation must be finished before the save is started")
            
            result.append(exp2)
            exp2.fulfill()
        }
        sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
                
        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(result, [exp1, exp2])
    }

    func test_ensureRequestsPerformInCorrectOrder() {
        let sut = makeSUT()

        _ = sut.logger.logs(from: anyDateBefore, to: currentDate)
        _ = sut.logger.logs(from: anyDateBefore, to: currentDate)
        sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
        _ = sut.logger.logFiles()
        sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
        _ = sut.logger.logs(from: anyDateBefore, to: currentDate)
        
        let result: [LogRequest] = [.load, .load, .write, .files, .write, .load]

        XCTAssertEqual(sut.logSaver.requests, result)
    }
    
    func test_ensureThreadLabelIsCorrect_ifRequestCalledInGlobalQueue() {
        let testQueue1 = DispatchQueue.global()
        let testQueue2 = DispatchQueue(label: "test.queue.label", qos: .utility)
        let testQueue3 = DispatchQueue(label: "test.queue.label", qos: .default, attributes: .concurrent)
        let testQueue4 = DispatchQueue.main

        checkLogFor(queue: testQueue1, contains: testQueue1.label)
        checkLogFor(queue: testQueue2, contains: testQueue2.label)
        checkLogFor(queue: testQueue3, contains: testQueue3.label)
        checkLogFor(queue: testQueue4, contains: "main")
    }
    
    func test_ensureThreadLabelIsCorrect_ifRequestCalledInQueueWithEmptyLabel() {
        let sut = makeSUT()
        let testQueue = DispatchQueue(label: "", qos: .default)
        let exp1 = expectation(description: "Write data")
        var threadId = ""

        testQueue.async { [self] in
            threadId = currentThreadId()
            sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
        }

        sut.logSaver.logCompletion = {
            exp1.fulfill()
        }

        waitForExpectations(timeout: 0.5)
        let result = self.contentOfLastCreatedFileWithoutHeaders()
        
        XCTAssert(result.contains(threadId))
    }
    
    func test_ensureThreadLabelIsCorrect_ifRequestCalledInOperationQueue() {
        let sut = makeSUT()
        let testQueue = OperationQueue()
        let exp1 = expectation(description: "Write data")
        var threadId = ""

        testQueue.addOperation { [self] in
            threadId = currentThreadId()
            sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
        }

        sut.logSaver.logCompletion = {
            exp1.fulfill()
        }

        waitForExpectations(timeout: 0.5)
        let result = self.contentOfLastCreatedFileWithoutHeaders()
        
        XCTAssert(result.contains(threadId))
    }
    
    func test_ensureWriteOperationIsFinishedBeforeFilesListReading() {
        let sut = makeSUT()
        var result = [XCTestExpectation]()
        
        let expWrite = expectation(description: "Write data")
        let expFilesList = expectation(description: "Read data")

        sut.logSaver.logCompletion = {
            Thread.sleep(forTimeInterval: 0.05)
            result.append(expWrite)
            expWrite.fulfill()
        }
        sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
             
        sut.filesExplorer.logFilesCompletion = {
            Thread.sleep(forTimeInterval: 0.025)
            XCTAssert(result.contains(expWrite),
                      "Write data operation must be finished before the read is started")
            result.append(expFilesList)
            expFilesList.fulfill()
        }
        _ = sut.logger.logFiles()
        
        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(result, [expWrite, expFilesList])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        let maxFilesCount: UInt = 10
        let maxFilesSize: UInt = 10000
        
        let logFormatter = LogFormatterImpl(config: testConfig)
        let headersFormatter = LogHeadersFormatterImpl(config: testConfig)
        let provider = FileActionProviderImpl(config: testConfig,
                                              maxFilesCount: maxFilesCount,
                                              maxFilesSize: maxFilesSize)
        let storage = LoggerStorageImpl(fileManager: fileManager,
                                        fileAttributeLoader: fileManager,
                                        config: testConfig)
        let logsExtractor = LogExtractorImpl(storage: storage, formatter: logFormatter)
        
        let manager = LoggerManager(actionProvider: provider,
                                    storage: storage,
                                    headersFormatter: headersFormatter,
                                    logsExtractor: logsExtractor,
                                    config: testConfig)
        
        let managerSpy = LoggerManagerSpy(manager: manager)
        
        let logger = LoggerImpl(logSaver: managerSpy,
                                logRetriever: managerSpy,
                                filesExplorer: managerSpy,
                                formatter: logFormatter,
                                config: testConfig)
        
        trackForMemoryLeaks(logFormatter, file: file, line: line)
        trackForMemoryLeaks(headersFormatter, file: file, line: line)
        trackForMemoryLeaks(provider, file: file, line: line)
        trackForMemoryLeaks(storage, file: file, line: line)
        trackForMemoryLeaks(logsExtractor, file: file, line: line)
        trackForMemoryLeaks(manager, file: file, line: line)
        trackForMemoryLeaks(managerSpy, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        
        return SUT(logSaver: managerSpy, logRetriever: managerSpy, filesExplorer: managerSpy, logger: logger)
    }
    
    private struct SUT {
        let logSaver: LoggerManagerSpy
        let logRetriever: LoggerManagerSpy
        let filesExplorer: LoggerManagerSpy
        let logger: Logger
    }
    
    private func checkLogFor(queue: DispatchQueue, contains threadLabel: String, file: StaticString = #filePath, line: UInt = #line) {
        let sut = makeSUT()
        let exp = expectation(description: "Any operation")
        
        queue.async { [self] in
            sut.logger.log(type: anyLogType, message: anyString, params: anyLogParams, tag: anyTag)
        }

        sut.logSaver.logCompletion = {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.5)
        
        let result = self.contentOfLastCreatedFileWithoutHeaders()

        XCTAssert(result.contains(threadLabel), file: file, line: line)
    }
    
    private func currentThreadId() -> String {
        var tid: __uint64_t = 0
        pthread_threadid_np(nil, &tid)
        return String(format: "%#08x", tid)
    }
}

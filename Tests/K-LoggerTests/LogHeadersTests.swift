//
//  LogHeadersTests.swift
//
//  Created by Volodymyr Kotsiubenko (31.01.2022).
//

import XCTest
@testable import K_Logger

final class LogHeadersTests: BaseLoggerTests {
    private lazy var headersFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = testConfig.headersDateFormat
        return formatter
    }()
        
    func test_ensureReturnedStringEmpty_afterInit() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.formatted().isEmpty)
    }
    
    func test_ensureReturnedResultContainsEncodingString() {
        let sut = makeSUT()
        
        sut.encoding = anyEncoding
        XCTAssertTrue(sut.formatted().contains(testConfig.encodingHeader))
    }
        
    func test_ensureReturnedResultContainsCorrectEncodingString() {
        let sut = makeSUT()
        
        sut.encoding = anyEncoding
        XCTAssertEqual(sut.formatted(), "\(testConfig.encodingHeader) \(anyEncoding)")
    }
    
    func test_ensureReturnedResultContainsVersionString() {
        let sut = makeSUT()
        
        sut.loggerVersion = anyVersion
        XCTAssertTrue(sut.formatted().contains(testConfig.versionHeader))
    }
    
    func test_ensureReturnedResultContainsCorrectVersionString() {
        let sut = makeSUT()
        
        sut.loggerVersion = anyVersion
        XCTAssertTrue(sut.formatted().contains("\(testConfig.versionHeader) \(anyVersion)"))
    }
    
    func test_ensureReturnedResultContainsDateString() {
        let sut = makeSUT()
        
        sut.creationDate = anyDate
        XCTAssertTrue(sut.formatted().contains(testConfig.dateHeader))
    }
    
    func test_ensureReturnedResultContainsConstantDateInCorrectFormatAndTimeZone() {
        let sut = makeSUT()
        
        sut.creationDate = currentDate
        XCTAssertEqual(sut.constantTimeZoneCreationDate, formattedDateString(from: currentDate, useSystemTimeZone: false))
    }
    
    func test_ensureReturnedResultContainsSystemDateInCorrectFormatAndTimeZone() {
        let sut = makeSUT()
        
        sut.creationDate = currentDate
        XCTAssertEqual(sut.systemTimeZoneCreationDate, formattedDateString(from: currentDate, useSystemTimeZone: true))
    }
    
    func test_ensureReturnedResultContainsCorrectDateString() throws {
        let sut = makeSUT()
        
        let testFile = try fileMeta()
        sut.creationDate = currentDate
        
        let constantTimeZoneCreationDate = formattedDateString(from: testFile.creationDate, useSystemTimeZone: false)
        let systemTimeZoneCreationDate = formattedDateString(from: testFile.creationDate, useSystemTimeZone: true)
        
        XCTAssertEqual(sut.formatted(), "\(testConfig.dateHeader) \(constantTimeZoneCreationDate) / \(systemTimeZoneCreationDate)")
    }
    
    func test_ensureReturnedResultContainsFieldsString() {
        let sut = makeSUT()
        
        sut.fields = anyFields
            XCTAssertTrue(sut.formatted().contains(testConfig.fieldsHeader))
    }
    
    func test_ensureReturnedResultContainsCorrectFieldsString() {
        let sut = makeSUT()
        
        sut.fields = anyFields
        XCTAssertEqual(sut.formatted(), "\(testConfig.fieldsHeader) \(anyFields)\n")
    }
    
    func test_ensureReturnedResultCorrect() {
        let sut = makeSUT()
        let date = currentDate
        let constantTimeZoneCreationDate = formattedDateString(from: date, useSystemTimeZone: false)
        let systemTimeZoneCreationDate = formattedDateString(from: date, useSystemTimeZone: true)
        
        sut.encoding = anyEncoding
        sut.creationDate = date
        sut.loggerVersion = anyVersion
        sut.fields = anyFields
       
        let expect = "\(testConfig.encodingHeader) \(anyEncoding)\n" +
        "\(testConfig.versionHeader) \(anyVersion)\n" +
        "\(testConfig.dateHeader) \(constantTimeZoneCreationDate) / \(systemTimeZoneCreationDate)\n" +
        "\(testConfig.fieldsHeader) \(anyFields)\n"
        XCTAssertEqual(sut.formatted(), expect)
    }
        
    // MARK: - Helpers
    private let anyVersion = "1.0.0"
    private let anyFields = "any Fields"
    private let anyDate = Date()
    private let anyEncoding = "UTF-8"
    
    private func makeSUT() -> LogHeadersFormatterImpl {
        LogHeadersFormatterImpl(config: testConfig)
    }
    
    private func formattedDateString(from date: Date, useSystemTimeZone: Bool) -> String {
        headersFormatter.timeZone = useSystemTimeZone ? nil : TimeZone(abbreviation: testConfig.timeZone)
        return headersFormatter.string(from: date)
    }
}

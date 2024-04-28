//
//  LineReaderImplTests.swift
//  LoggerTests
//
//  Created by Volodymyr Kotsiubenko (02.02.2022).
//

import XCTest
@testable import K_Logger

final class LineReaderImplTests: BaseLoggerTests {
    func test_ensureObjectNil_ifFileByPathNonexistent() {
        let sut = makeSUT(testFilePath: "")
        
        XCTAssertNil(sut)
    }
    
    func test_ensureObjectNotNil_ifFileAtPathExists() throws {
        let testFile = try createTestFile()
        let sut = makeSUT(testFilePath: testFile.url.path)
        
        XCTAssertNotNil(sut)
    }
    
    func test_nextLine_ensureResultNil_ifFileIsEmpty() throws {
        let sut = try makeNotNilSUT()
        
        XCTAssertEqual(sut?.nextLine, nil)
    }
    
    func test_nextLine_ensureResultNotNil_ifFileNotEmpty() throws {
        let sut = try makeNotNilSUT(withContent: anyString)

        XCTAssertNotNil(sut?.nextLine)
    }
    
    func test_nextLine_ensureResultOfFirstCallCorrect() throws {
        let testContent = "test content"
        let sut = try makeNotNilSUT(withContent: testContent)
        
        XCTAssertEqual(sut?.nextLine, testContent)
    }
    
    func test_nextLine_ensureResultCorrect_forMultipleCalls() throws {
        let multilineTestContent = "test content line1\ntest content line2\ntest content line3"
        let sut = try makeNotNilSUT(withContent: multilineTestContent)

        var result = ""
    
        for _ in 0...2 {
            result += sut?.nextLine ?? ""
        }
        
        XCTAssertEqual(result, multilineTestContent)
    }
    
    func test_nextLine_ensureResultNil_whenContentEnded() throws {
        let sut = try makeNotNilSUT(withContent: "test content line1\ntest content line2")

        var result: String?
    
        for i in 0...2 {
            if i == 2 {
                result = sut?.nextLine
            } else {
                _ = sut?.nextLine
            }
        }
        
        XCTAssertNil(result)
    }
    
    func test_nextLine_ensureResultCorrect_forNonAlphabetSymbols() throws {
        let testContent = "K&#*)!+_)(*&^%$!: +_)(*&^%$#@!±😊"
        let sut = try makeNotNilSUT(withContent: testContent)

        XCTAssertEqual(sut?.nextLine, testContent)
    }
    
    func test_nextLine_ensureResultCorrect_forNonCyrillicSymbols() throws {
        let testContent = "Кирилица кирилица"
        let sut = try makeNotNilSUT(withContent: testContent)

        XCTAssertEqual(sut?.nextLine, testContent)
    }
    
    // MARK: - Helpers
    private func makeNotNilSUT(withContent content: String = "",
                               testFilePath: String? = nil,
                               file: StaticString = #filePath,
                               line: UInt = #line) throws -> LineReader? {
        let testFile = try createTestFile(content: content)
        let sut = makeSUT(testFilePath: testFilePath ?? testFile.url.path)
        
        XCTAssertNotNil(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeSUT(testFilePath: String) -> LineReader? {
        LineReaderImpl(path: testFilePath)
    }
}

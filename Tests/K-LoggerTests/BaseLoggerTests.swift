//
//  BaseLoggerTests.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (31.01.2022).
//

import XCTest
@testable import K_Logger

fileprivate extension LogEventType {
    static var allCases: [LogEventType] = [.info, .debug, .warning, .error, .critical, .user(label: "label")]
}

class BaseLoggerTests: BaseLogFileTest {
    override func setUp() {
        super.setUp()
        createLogFolder()
    }
    
    override func tearDown() {
        super.tearDown()
        deleteLogFolder()
    }
        
    private lazy var logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = testConfig.logDateFormat
        formatter.timeZone = TimeZone(abbreviation: testConfig.timeZone)
        return formatter
    }()
    
    lazy var anyValidHeaders: String = {
        let constantTimeZoneDate = formattedDateForHeaders(from: currentDate, forUserTimeZone: false)
        let systemTimeZoneDate = formattedDateForHeaders(from: currentDate, forUserTimeZone: true)
        
        return "\(testConfig.encodingHeader) UTF-8\n" +
        "\(testConfig.versionHeader) 2.01.1\n" +
        "\(testConfig.dateHeader) \(constantTimeZoneDate) / \(systemTimeZoneDate)\n" +
        "\(testConfig.fieldsHeader) some fields\n\n"
    }()
    
    lazy var anyDateBefore: Date = dayBefore

    let fileManager = FileManager.default
    let anyLogParams = ["Any param key": "Any param value"]
    let anyTag = "Any Tag"
    let anyThreadLabel = "Any ThreadLabel"
    let anyMessage = "Any Message"
    let anyLogType: LogEventType = .info
        
    var anyEventType: LogEventType {
        LogEventType.allCases.randomElement() ?? .info
    }
    
    @discardableResult
    func createTestFile(creationDate: Date = Date(),
                        content: String = "") throws -> FileMetaImpl {
        let path = pathForFileName(fileNameByDate(currentDate))
        
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
        
        let encodedData = content != "" ? Data(content.utf8) : nil
        
        fileManager.createFile(atPath: path, contents: encodedData)
        
        return try fileMetaForFile(fileUrl: URL(fileURLWithPath: path))
    }
    
    func createTestFiles(withContent content: String = "", number: UInt) throws -> [FileMetaImpl] {
        var result = [FileMetaImpl]()
        
        for _ in 1...number {
            wait()
            result.append(try createTestFile(content: content))
        }
                          
        return result
    }
    
    func createLogFolder() {
        try? fileManager.createDirectory(atPath: testConfig.logsFolder, withIntermediateDirectories: true, attributes: nil)
    }
    
    func deleteLogFolder() {
        try? fileManager.removeItem(atPath: testConfig.logsFolder)
    }
    
    func existingLogFiles() -> [FileMetaImpl] {
        var result = [FileMetaImpl]()
        
        if let files = try? fileManager.contentsOfDirectory(atPath: testConfig.logsFolder) {
            for file in files where file.hasSuffix(testConfig.fileExtension) {
                if let fileMeta = try? FileMetaImpl(url: URL(fileURLWithPath: testConfig.fullFileName(fromFileName: file)),
                                                    loader: fileManager,
                                                    config: testConfig) {
                    result.append(fileMeta)
                }
            }
        }
        return result
    }

    func fileMetas(count: Int, filesSize: UInt = 1, file: StaticString = #filePath, line: UInt = #line) throws -> [FileMetaImpl] {
        let fileUrls = filesUrls(count: count)
        return try fileMetas(urls: fileUrls, fileSize: filesSize)
    }
    
    func formattedDateForHeaders(from date: Date, forUserTimeZone: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = testConfig.headersDateFormat
        formatter.timeZone = forUserTimeZone ? TimeZone(abbreviation: testConfig.timeZone) : nil
        return formatter.string(from: date)
    }
    
    func validLogStringByCurrentDate() -> String {
        logFormatter.string(from: Date())
    }
    
    func contentOfLastCreatedFile() -> String {
        guard let file = existingLogFiles().sorted().last else { return "" }
        if let content = try? String(contentsOf: file.url, encoding: testConfig.encoding.stringEncoding) {
            return content
        }
        return ""
    }
    
    func contentOfLastCreatedFileWithoutHeaders() -> String {
        let content = contentOfLastCreatedFile()
        
        if let range = content.range(of: "\n\n") {
            let indexOfHeadersEnd: Int = content.distance(from: content.startIndex, to: range.upperBound)
            return String(content.dropFirst(indexOfHeadersEnd))
        }
        
        return ""
    }
    
    func fileMetas(urls: [URL], fileSize: UInt = 1) throws -> [FileMetaImpl] {
        try urls.map { try FileMetaImpl(url: $0, loader: anyLoader(testFileSize: fileSize), config: testConfig) }
    }
    
    // MARK: - Private
    private func filesUrls(count: Int) -> [URL] {
        var result = [URL]()
        
        for _ in 1...count {
            wait()
            result.append(URL(fileURLWithPath: fileNameByDate(currentDate)))
        }
                          
        return result
    }
}

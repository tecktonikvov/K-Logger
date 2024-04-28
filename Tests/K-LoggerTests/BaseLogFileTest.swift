//
//  BaseLogFileTest.swift
//  LoggerTests
//
//  Created by Volodymyr Kotsiubenko (21.01.2022).
//

import XCTest
@testable import K_Logger

class BaseLogFileTest: XCTestCase {
    var currentDate: Date {
        Date()
    }
    
    let anyString = "some string"
    
    let testConfig = DefaultLoggerConfig()
    
    var dayBefore: Date {
        .dayBefore(usingCalendar: testConfig.calendar)
    }
    
    var twoDaysBefore: Date {
        .twoDaysBefore(usingCalendar: testConfig.calendar)
    }
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = testConfig.fileNameFormat
        formatter.timeZone = TimeZone(abbreviation: testConfig.timeZone)
        return formatter
    }()
    
    func fileNameByDate(_ date: Date) -> String {
        "\(testConfig.fileNamePrefix)-\(formatter.string(from: date))\(testConfig.fileExtension)"
    }
    
    func fileNameByDateWithoutExtension(_ date: Date) -> String {
        String(fileNameByDate(date).dropLast(testConfig.fileExtension.count))
    }
    
    func anyLoader(testFileSize: UInt) -> FileAttributeLoader {
        TestFileAttributeLoader(fileSize: testFileSize)
    }
   
    struct TestFileAttributeLoader: FileAttributeLoader {
        var fileSize: UInt = 0
        
        var creationDate = Date()
        
        func fileAttributes(atUrl url: URL) -> [FileAttributeKey: Any]? {
            [.size: fileSize,
             .creationDate: creationDate]
        }
    }
    
    func pathForFileName(_ fileName: String) -> String {
        testConfig.fullFileName(fromFileName: fileName)
    }
    
    func fileMeta(creationDate: Date = Date(), size: UInt? = nil) throws -> FileMetaImpl {
        let fullPath = pathForFileName(fileNameByDateWithoutExtension(creationDate)) + testConfig.fileExtension
        return try fileMetaForFile(fileUrl: URL(fileURLWithPath: fullPath), size: size)
    }
    
    func fileMetaForFile(fileUrl: URL, size: UInt? = nil) throws -> FileMetaImpl {
        let loader = size == nil ? FileManager.default : anyLoader(testFileSize: size ?? 0)
        return try FileMetaImpl(url: fileUrl, loader: loader, config: testConfig) 
    }
    
    func anyFileSize() -> UInt {
        4
    }
    
    func wait() {
        Thread.sleep(forTimeInterval: 0.001)
    }
}

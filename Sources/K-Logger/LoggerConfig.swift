//
//  LogsConfig.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (14/2/22).

import Foundation

protocol LoggerConfig {
    var calendar: Calendar { get }
    var loggerVersion: String { get }
    var fileExtension: String { get }
    var encoding: LogsEncoding { get }
    
    var currentDate: Date { get }
    
    var fileNameFormat: String { get }
    var logDateFormat: String { get }
    var headersDateFormat: String { get }
    
    var fileNamePrefix: String { get }
    
    var timeZone: String { get }
    var locale: String { get }
    var logsFolder: String { get }
    
    var paramsPrefix: String { get }
    var fields: String { get }
    
    var encodingHeader: String { get }
    var versionHeader: String { get }
    var dateHeader: String { get }
    var fieldsHeader: String { get }
    
    func fullFileName(fromFileName fileName: String) -> String
}

struct DefaultLoggerConfig: LoggerConfig {
    private static let _timeZone = "UTC"
    private static let _locale = "en_US_POSIX"

    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        if let timeZone = TimeZone(abbreviation: DefaultLoggerConfig._timeZone) {
            calendar.timeZone = timeZone
        }
        return calendar
    }()
    
    let loggerVersion = "1.0.0"
    let fileExtension = ".log"
    let encoding: LogsEncoding = .utf8
    
    var currentDate: Date {
        Date()
    }
    
    let fileNameFormat = "yyyy-MM-dd HH-mm-ss SSS"
    let logDateFormat = "yyyy-MM-dd HH:mm:ss.SSSX"
    let headersDateFormat = "yyyy-MM-dd HH:mm O"
    
    let fileNamePrefix = "main"
    
    var timeZone: String {
        DefaultLoggerConfig._timeZone
    }
    
    var locale: String {
        DefaultLoggerConfig._locale
    }
    
    var logsFolder: String {
        logsFolderURL.path
    }
    
    let paramsPrefix = "#PR"
    let fields = "timestamp level [thread, *tag] message *params"
    
    let encodingHeader = "#Encoding:"
    let versionHeader = "#Version:"
    let dateHeader = "#Date:"
    let fieldsHeader = "#Fields:"

    func fullFileName(fromFileName fileName: String) -> String {
        logsFolderURL.appendingPathComponent(fileName).path
    }
    
    // MARK: - Private
    private let logsFolderURL: URL = {
        let fileManager = FileManager.default
        guard let baseUrl = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return fileManager.temporaryDirectory
        }
        
        return baseUrl.appendingPathComponent("Logs")
    }()
}

//
//  LogHeadersImpl.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (31.01.2022).

import Foundation

final class LogHeadersFormatterImpl {
    var encoding: String?
    var creationDate: Date?
    var loggerVersion: String?
    var fields: String?
    
    private let config: LoggerConfig
    
    var constantTimeZoneCreationDate: String {
        formattedDateString(from: creationDate ?? Date(), useSystemTimeZone: false)
    }
    
    var systemTimeZoneCreationDate: String {
        formattedDateString(from: creationDate ?? Date(), useSystemTimeZone: true)
    }
    
    init(config: LoggerConfig) {
        self.config = config
    }
    
    func formatted() -> String {
        var components = [String]()
            
        if let encoding = encoding {
            components.append("\(config.encodingHeader) \(encoding)")
        }
        
        if let loggerVersion = loggerVersion {
            components.append("\(config.versionHeader) \(loggerVersion)")
        }
        
        if creationDate != nil {
            components.append("\(config.dateHeader) \(constantTimeZoneCreationDate) / \(systemTimeZoneCreationDate)")
        }
        
        if let fields = fields {
            components.append("\(config.fieldsHeader) \(fields)\n")
        }
        
        let formattedString = components.joined(separator: "\n")
        
        return formattedString
    }
    
    private func formattedDateString(from date: Date, useSystemTimeZone: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = config.headersDateFormat
        formatter.timeZone = useSystemTimeZone ? nil : TimeZone(abbreviation: config.timeZone)
        formatter.locale = Locale(identifier: config.locale)
        return formatter.string(from: date)
    }
}

// MARK: - LogHeadersFormatter
extension LogHeadersFormatterImpl: LogHeadersFormatter {
    func headersLinesCount() -> Int {
        4
    }
    
    func formattedString(fileCreationDate: Date,
                         encoding: String,
                         loggerVersion: String,
                         fields: String) -> String {
        self.encoding = encoding
        self.creationDate = fileCreationDate
        self.loggerVersion = loggerVersion
        self.fields = fields
        
        return formatted()
    }
}

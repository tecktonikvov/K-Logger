//
//  FileMeta.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (19.01.2022).

import Foundation

protocol FileMeta {
    var url: URL { get }
    var fileSize: UInt { get }
    var fileName: String { get }
    var creationDate: Date { get }
}

// MARK: - Protocol Extension
extension FileMeta {
    var fileName: String {
        url.lastPathComponent
    }
    
    static func convertToDate(fileName: String, config: LoggerConfig) throws -> Date {
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = config.fileNameFormat
            formatter.timeZone = TimeZone(abbreviation: config.timeZone)
            formatter.locale = Locale(identifier: config.locale)
            return formatter
        }()
        
        let fileNameWithoutPrefix = String(fileName.dropFirst(config.fileNamePrefix.count + 1))
        let dateFromFileName = String(fileNameWithoutPrefix.prefix(config.fileNameFormat.count))
        
        if let creationDateFromFileName = formatter.date(from: dateFromFileName) {
            return creationDateFromFileName
        }
        
        throw LogFileError.invalidFileName
    }
}

// MARK: - Comparable
extension FileMetaImpl: Comparable {
    public static func < (lhs: FileMetaImpl, rhs: FileMetaImpl) -> Bool {
        lhs.creationDate < rhs.creationDate
    }
    
    public static func == (lhs: FileMetaImpl, rhs: FileMetaImpl) -> Bool {
        lhs.url == rhs.url
    }
}

// MARK: - LogFileError
enum LogFileError: LocalizedError {
    case invalidFileName
    
    public var errorDescription: String? {
        switch self {
        case .invalidFileName:
            return "File name does not match the specified format"
        }
    }
}

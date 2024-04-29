//
//  Logger.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (22.12.2021).

import Foundation

protocol Logger {
    /// Saves the given data of the specified type to a logging storage.
    /// A storage is defined by the concrete logger implementation.
    /// - Parameters:
    ///   - type: Event type identifier. Can be used for filtering logs by priority. For all possible types please refer to ``LogEventType``
    ///   - message: A string value that is used as a content of the log record.
    ///   - params: Optional parameters that can be used to write additional important information. For example, the dictionary may be written as JSON (the format will depend on the concrete logger implementation)
    ///   - tag: An optional tag string that is written after the thread label. Can be used to mark some records for future identification. For instance, you can set the tag to "REST" for all network requests to be able to filter only records written by the networking module.
    func log(type: LogEventType, message: String, params: [String: Any]?, tag: String?)
    
    /// Saves the given data of the specified type to a logging storage as debug event.
    func debug(_ message: String, params: [String: Any]?, tag: String?)
    
    /// Saves the given data of the specified type to a logging storage as info event.
    func info(_ message: String, params: [String: Any]?, tag: String?)
    
    /// Saves the given data of the specified type to a logging storage as critical event.
    func critical(_ message: String, params: [String: Any]?, tag: String?)
    
    /// Saves the given data of the specified type to a logging storage as warning event.
    func warning(_ message: String, params: [String: Any]?, tag: String?)
    
    /// Saves the given data of the specified type to a logging storage as error event.
    func error(_ message: String, params: [String: Any]?, tag: String?)
    
    /// Saves the given data of the specified type to a logging storage as user event (contains user label).
    func user(_ message: String, label: String, params: [String: Any]?, tag: String?)
    
    /// Returns logs for the specified date range
    func logs(from startDate: Date, to endDate: Date) -> Data
    
    /// Returns list of logs files existing in the log folder
    func logFiles() -> [LogFile]
    
    /// Returns a directory path to a folder where log files are stored
    func logsFolderPath() -> String
}

// MARK: - Protocol Extension
extension Logger {
    func log(type: LogEventType, message: String, params: [String: Any]? = nil, tag: String? = nil) {
        log(type: type, message: message, params: params, tag: tag)
    }

    func debug(_ message: String, params: [String: Any]? = nil, tag: String? = nil) {
        log(type: .debug, message: message, params: params, tag: tag)
    }
    
    func info(_ message: String, params: [String: Any]? = nil, tag: String? = nil) {
        log(type: .info, message: message, params: params, tag: tag)
    }
    
    func critical(_ message: String, params: [String: Any]? = nil, tag: String? = nil) {
        log(type: .critical, message: message, params: params, tag: tag)
    }
    
    func warning(_ message: String, params: [String: Any]? = nil, tag: String? = nil) {
        log(type: .warning, message: message, params: params, tag: tag)
    }
    
    func error(_ message: String, params: [String: Any]? = nil, tag: String? = nil) {
        log(type: .error, message: message, params: params, tag: tag)
    }
    
    func user(_ message: String, label: String = "", params: [String: Any]? = nil, tag: String? = nil) {
        log(type: .user(label: label), message: message, params: params, tag: tag)
    }
}

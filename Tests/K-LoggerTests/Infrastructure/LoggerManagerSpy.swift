//
//  LoggerManagerSpy.swift
//  LoggerTests
//
//  Created by Volodymyr Kotsiubenko (10.02.2022).
//

import Foundation
@testable import K_Logger

final class LoggerManagerSpy {
    private let manager: LoggerManager
    
    init(manager: LoggerManager) {
        self.manager = manager
    }
    
    // MARK: - Tests
    var logCompletion: (() -> Void)?
    var logsCompletion: (() -> Void)?
    var logFilesCompletion: (() -> Void)?

    private(set) var requests = [LogRequest]()
}

// MARK: - LogSaver
extension LoggerManagerSpy: LogSaver {
    func saveLog(_ log: String) {
        requests.append(.write)
        manager.saveLog(log)
        logCompletion?()
    }
}

// MARK: - LogRetriever
extension LoggerManagerSpy: LogRetriever {
    func logs(from fromDate: Date, to toDate: Date) -> String {
        requests.append(.load)
        defer {
            logsCompletion?()
        }
        return manager.logs(from: fromDate, to: toDate)
    }
}

// MARK: - FilesExplorer
extension LoggerManagerSpy: FilesExplorer {
    func logFiles() -> [LogFile] {
        requests.append(.files)
        defer {
            logFilesCompletion?()
        }
        return manager.logFiles()
    }
}

enum LogRequest {
    case write, load, files
}

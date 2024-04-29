//
//  LoggerManager.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (27.01.2022).

import Foundation

final class LoggerManager {
    private let actionProvider: FileActionProvider
    private let storage: LoggerStorage
    private let headersFormatter: LogHeadersFormatter
    private let logsExtractor: LogExtractor
    
    private let config: LoggerConfig
    
    init(actionProvider: FileActionProvider,
         storage: LoggerStorage,
         headersFormatter: LogHeadersFormatter,
         logsExtractor: LogExtractor,
         config: LoggerConfig) {
        self.actionProvider = actionProvider
        self.headersFormatter = headersFormatter
        self.storage = storage
        self.logsExtractor = logsExtractor
        self.config = config
    }
    
    private func create(fileWithName newFileName: String, thenWrite log: String) {
        if let newFile = try? storage.createFile(withName: newFileName) {
            writeHeaders(to: newFile)
            saveLog(log, to: newFile)
        }
    }
    
    private func writeHeaders(to file: FileMeta) {
        let headers = generateHeaders(with: file.creationDate)
        saveLog("\(headers)", to: file)
    }
    
    private func generateHeaders(with fileCreationDate: Date) -> String {
        headersFormatter.formattedString(fileCreationDate: fileCreationDate,
                                         encoding: config.encoding.rawValue,
                                         loggerVersion: config.loggerVersion,
                                         fields: config.fields)
    }
    
    private func saveLog(_ log: String, to file: FileMeta) {
        storage.saveLog("\(log)\n", to: file)
    }
}

// MARK: - LogSaver
extension LoggerManager: LogSaver {
    func saveLog(_ log: String) {
        let logSize = storage.logSize(log)
        let allFilesMeta = storage.metaForAllFiles()
        
        let action = actionProvider.actionForLog(ofSize: logSize, using: allFilesMeta)
        switch action {
        case .create(let fileName):
            create(fileWithName: fileName, thenWrite: log)
        case .write(let file):
            saveLog(log, to: file)
        case .rotation(let fileToDelete, let newFileName):
            storage.deleteFile(fileToDelete)
            create(fileWithName: newFileName, thenWrite: log)
        case .skip:
            break
        }
    }
}

// MARK: - LogRetriever
extension LoggerManager: LogRetriever {
    func logs(from fromDate: Date, to toDate: Date) -> String {
        logsExtractor.extractContent(from: fromDate, to: toDate)
    }
}

// MARK: - FilesExplorer
extension LoggerManager: FilesExplorer {
    func logFiles() -> [LogFile] {
        storage.logFiles()
    }
}

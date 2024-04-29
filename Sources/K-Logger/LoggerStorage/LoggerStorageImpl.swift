//
//  LoggerStorageImpl.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (21.01.2022).

import Foundation

final class LoggerStorageImpl {
    private var fileHandler: LogFileImpl?
    private let fileManager: LoggerFileStorage
    private let fileAttributeLoader: FileAttributeLoader
    
    private let config: LoggerConfig
        
    init(fileManager: LoggerFileStorage,
         fileAttributeLoader: FileAttributeLoader,
         config: LoggerConfig) {
        self.fileManager = fileManager
        self.fileAttributeLoader = fileAttributeLoader
        self.config = config
    }
    
    private func setHandlerFor(file url: URL) {
        guard let handler = try? LogFileImpl(forAction: .write, fileUrl: url, config: config) else { return }
        fileHandler = handler
    }
    
    private func createLogsFolderIfNeeded() {
        fileManager.createLogsFolder(atPath: config.logsFolder)
    }
    
    private func deleteFile(atUrl url: URL) {
        fileManager.deleteFile(atPath: url.path)
    }
}

// MARK: - LoggerStorage
extension LoggerStorageImpl: LoggerStorage {
    func metaForAllFiles() -> [FileMeta] {
        let files = fileManager.filesNames(atPath: config.logsFolder)
        
        return files.compactMap {
            let fileUrl = URL(fileURLWithPath: config.fullFileName(fromFileName: $0))
            
            do {
                let file = try FileMetaImpl(
                    url: fileUrl,
                    loader: fileAttributeLoader,
                    config: config)
                return file
            } catch {
                deleteFile(atUrl: fileUrl)
                return nil
            }
        }
    }
    
    func log(fromFile file: FileMeta, offset: UInt) -> String {
        guard let handler = try? LogFileImpl(forAction: .read, fileUrl: file.url, config: config) else { return "" }
        let dataWithOffset = try? handler.read(offset: offset)
        
        return String(data: dataWithOffset ?? Data(), encoding: config.encoding.stringEncoding) ?? ""
    }
    
    func saveLog(_ log: String, to file: FileMeta) {
        if fileHandler?.url == file.url {
            try? fileHandler?.write(log)
        } else {
            setHandlerFor(file: file.url)
            try? fileHandler?.write(log)
        }
    }
    
    func deleteFile(_ file: FileMeta) {
        fileManager.deleteFile(atPath: file.url.path)
            
        if fileHandler?.url == file.url {
            fileHandler = nil
        }
    }
    
    func createFile(withName fileName: String) throws -> FileMeta {
        createLogsFolderIfNeeded()
        
        let newFilePath = config.fullFileName(fromFileName: fileName)
        
        fileManager.createFile(atPath: newFilePath)
        setHandlerFor(file: URL(fileURLWithPath: newFilePath))
        
        if let fileHandler = fileHandler {
            return fileHandler
        } else {
            return try FileMetaImpl(url: URL(fileURLWithPath: newFilePath), loader: fileManager, config: config)
        }
    }
    
    func logSize(_ log: String) -> UInt {
        UInt(log.lengthOfBytes(using: config.encoding.stringEncoding))
    }
    
    func currentFileMeta() -> FileMeta? {
        fileHandler
    }
    
    func readerFor(file: FileMeta) -> LineReader?{
        LineReaderImpl(path: file.url.path)
    }
    
    func logFiles() -> [LogFile] {
        fileManager.files(inDirectory: config.logsFolder).map {
            LogFile(fileUrl: URL(fileURLWithPath: config.fullFileName(fromFileName: $0)))
        }
    }
}

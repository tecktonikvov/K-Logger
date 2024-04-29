//
//  FileActionProviderImpl.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (13.01.2022).

import Foundation

final class FileActionProviderImpl {
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = config.fileNameFormat
        formatter.timeZone = TimeZone(abbreviation: config.timeZone)
        formatter.locale = Locale(identifier: config.locale)
        return formatter
    }()
        
    private let maxFilesCount: UInt
    private let maxFilesSize: UInt
    
    private var maxFileSize: UInt {
        maxFilesCount != 0 ? maxFilesSize / maxFilesCount : 0
    }
    
    private let config: LoggerConfig
    
    init(config: LoggerConfig, maxFilesCount: UInt, maxFilesSize: UInt) {
        self.maxFilesCount = maxFilesCount
        self.maxFilesSize = maxFilesSize
        self.config = config
    }
}

// MARK: - FileActionProvider
extension FileActionProviderImpl: FileActionProvider {
    func actionForLog(ofSize recordSize: UInt, using fileMetas: [FileMeta]) -> FileAction {
        guard maxFilesCount != 0,
              maxFilesSize != 0,
              recordSize <= maxFileSize else { return .skip }
        
        let allFileMetas = fileMetas.unique.sorted(by: { $0.creationDate < $1.creationDate })
        
        if let file = allFileMetas.last, isForSameDay(file) {
            if canWrite(dataWithSize: recordSize, to: file) {
                return .write(file: file)
            }
        }
        
        return createRotationOrSkip(recordSize: recordSize, fileMetas: allFileMetas)
    }
    
    private func isForSameDay(_ file: FileMeta) -> Bool {
        config.calendar.isDate(file.creationDate, inSameDayAs: Date())
    }
    
    private func createRotationOrSkip(recordSize: UInt, fileMetas: [FileMeta]) -> FileAction {
        let newFileName = newFileName() + config.fileExtension

        if canCreateFile(withInitialDataSize: recordSize, from: fileMetas) {
            return .create(fileName: newFileName)
        }
        
        if let fileForDrop = fileForDrop(from: fileMetas) {
            return .rotation(dropFile: fileForDrop, newFileName: newFileName)
        }
        
        return .skip
    }
     
    private func canWrite(dataWithSize: UInt, to file: FileMeta) -> Bool {
        (file.fileSize + dataWithSize) <= maxFileSize
    }
    
    private func canCreateFile(withInitialDataSize sizeForWrite: UInt,
                               from fileMetas: [FileMeta]) -> Bool {
        maxFilesCount > fileMetas.count && (allFilesSize(from: fileMetas) + sizeForWrite) <= maxFilesSize
    }
    
    private func fileForDrop(from fileMetas: [FileMeta]) -> FileMeta? {
        fileMetas.sorted { $0.creationDate < $1.creationDate }.first
    }

    private func allFilesSize(from fileMetas: [FileMeta]) -> UInt {
        fileMetas.reduce(0) { $0 + $1.fileSize }
    }
    
    private func newFileName() -> String {
        config.fileNamePrefix + "-" + formatter.string(from: config.currentDate)
    }
}

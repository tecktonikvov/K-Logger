//
//  LogExtractorImpl.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (03.02.2022).

import Foundation

final class LogExtractorImpl {
    private let storage: LoggerStorage
    private let formatter: LogExtractorFormatter

    // MARK: - Init
    init(storage: LoggerStorage, formatter: LogExtractorFormatter) {
        self.storage = storage
        self.formatter = formatter
    }

    private func makeFileQueue(from startDate: Date, to endDate: Date) -> [File] {
        let files = fetchFiles()
        let metasForPartReading = filesForPartReading(from: startDate, to: endDate, fromFiles: files)
        let metasForFullReading = filesForFullReading(filesForPartReading: metasForPartReading,
                                                      allFiles: files,
                                                      from: startDate,
                                                      to: endDate)
        
        let partReadingFiles = metasForPartReading.map { File(type: .partReadFile, meta: $0) }
        let fullReadingFiles = metasForFullReading.map { File(type: .fullReadFile, meta: $0) }

        return (partReadingFiles + fullReadingFiles).sorted { $0.meta.creationDate < $1.meta.creationDate }
    }
    
    private func filesForFullReading(filesForPartReading: [FileMeta],
                                     allFiles: [FileMeta],
                                     from fromDate: Date,
                                     to toDate: Date) -> [FileMeta] {
        let metasWithoutPartReadingFiles = removePartReadingFiles(filesForPartReading: filesForPartReading,
                                                                  fromFiles: allFiles)
        return metasWithoutPartReadingFiles.filter { $0.creationDate >= fromDate && $0.creationDate < toDate }
    }
    
    private func removePartReadingFiles(filesForPartReading: [FileMeta], fromFiles files: [FileMeta]) -> [FileMeta] {
        files.filter { !filesForPartReading.map { $0.url }.contains($0.url) }
    }
    
    private func filesForPartReading(from fromDate: Date, to toDate: Date, fromFiles files: [FileMeta]) -> [FileMeta] {
        let startFileForPartRead = files.last { $0.creationDate <= fromDate }
        let endFileForPartRead = files.last { $0.creationDate <= toDate && $0.creationDate > fromDate }
                
        return [startFileForPartRead, endFileForPartRead].compactMap { $0 }.unique
    }
    
    private func content(of file: FileMeta) -> String {
         storage.log(fromFile: file, offset: headerSize(from: file))
    }

    private func content(of file: FileMeta, from startDate: Date, to endDate: Date) -> String {
        guard let lineReader = storage.readerFor(file: file) else { return "" }
        var result = ""
        var collectedLines = ""
        
        while let line = lineReader.nextLine {
            let datePrefix = String(line.prefix(formatter.dateStringSize))

            // If we can get date from line prefix it means than
            // the line is start of log
            if let logDate = formatter.date(from: datePrefix) {
                // And firs we must to clear temporary var
                if !collectedLines.isEmpty {
                    result += collectedLines
                    collectedLines = ""
                }
                
                // Next we check what needs to be done with the line based on the date
                switch actionForLine(byDate: logDate, startDate: startDate, endDate: endDate) {
                case .save:
                    collectedLines = line
                case .ignore:
                    break
                case .finishReading:
                    return result
                }
            } else {
                // If getting the date failed it means that current line is not first line of log.
                // Add it to temporary var
                if !collectedLines.isEmpty {
                    collectedLines += line
                }
            }
        }
        
        result += collectedLines

        return result
    }
    
    private func actionForLine(byDate date: Date, startDate: Date, endDate: Date) -> ActionForLine {
        if date < startDate {
            return .ignore
        } else if date >= startDate && date <= endDate {
            return .save
        } else if date > endDate {
            return .finishReading
        }
        return .finishReading
    }
    
    private func headerSize(from file: FileMeta) -> UInt {
        guard let lineReader = storage.readerFor(file: file) else { return 0 }
        
        var result = UInt()
        
        while let line = lineReader.nextLine {
            if line == "\n" {
                return result
            }
            result += storage.logSize(line)
        }
        
        return result
    }
    
    private func fetchFiles() -> [FileMeta] {
        storage.metaForAllFiles()
    }
}

// MARK: - LogExtractor
extension LogExtractorImpl: LogExtractor {
    func extractContent(from startDate: Date, to endDate: Date) -> String {
        var contentComponents = [String]()
        
        for nextFile in makeFileQueue(from: startDate, to: endDate) {
            switch nextFile.type {
            case .partReadFile:
                let content = self.content(of: nextFile.meta,
                                           from: startDate,
                                           to: endDate).trimmingCharacters(in: .newlines)
                contentComponents.append(content)
            case .fullReadFile:
                contentComponents.append(self.content(of: nextFile.meta).trimmingCharacters(in: .newlines))
            }
        }
                
        return contentComponents.joined(separator: "\n")
    }
}

// MARK: - extension LogExtractorImpl
private extension LogExtractorImpl {
    enum FileType {
        case partReadFile, fullReadFile
    }

    struct File {
        let type: FileType
        let meta: FileMeta
    }
    
    enum ActionForLine {
        case save, ignore, finishReading
    }
}

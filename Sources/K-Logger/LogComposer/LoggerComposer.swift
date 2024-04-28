//
//  LoggerComposer.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (14/2/22).

import Foundation

public final class LoggerComposer {
    /// Returns instance of ``Logger``.
    /// 
    /// ``Logger`` uses the device file system as storage and store logs files in Library/Application Support/Logs directory.
    ///  
    /// - Parameters:
    ///   - maxFilesSize: Defines the total maximum disk space for log files in bytes. Min - 1, max - no limit. Default 20mb, (0 will disable logging).
    ///   - maxFilesCount: Defines the maximum number of stored files on a disk. Min - 1, max - no limit. Default 40, (0 will disable logging).
    ///
    public static func makeDiskLogger(maxFilesSize: UInt = 10 * 1024 * 1024, maxFilesCount: UInt = 10) -> Logger {
        let fileManager = FileManager.default
        let defaultConfig = DefaultLoggerConfig()
        let logFormatter = LogFormatterImpl(config: defaultConfig)
        let headersFormatter = LogHeadersFormatterImpl(config: defaultConfig)
        let provider = FileActionProviderImpl(config: defaultConfig,
                                              maxFilesCount: maxFilesCount,
                                              maxFilesSize: maxFilesSize)
        let storage = LoggerStorageImpl(fileManager: fileManager,
                                        fileAttributeLoader: fileManager,
                                        config: defaultConfig)
        let logsExtractor = LogExtractorImpl(storage: storage, formatter: logFormatter)
        
        let manager = LoggerManager(actionProvider: provider,
                                    storage: storage,
                                    headersFormatter: headersFormatter,
                                    logsExtractor: logsExtractor,
                                    config: defaultConfig)
        
        return LoggerImpl(logSaver: manager,
                          logRetriever: manager,
                          filesExplorer: manager,
                          formatter: logFormatter,
                          config: defaultConfig)
    }
}

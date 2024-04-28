//
//  LoggerImpl.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (10.02.2022).

import Foundation

final class LoggerImpl {
    private let config: LoggerConfig
    
    private let logSaver: LogSaver
    private let logRetriever: LogRetriever
    private let filesExplorer: FilesExplorer
    private let logFormatter: LogFormatter

    private var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: - Init
    init(logSaver: LogSaver,
         logRetriever: LogRetriever,
         filesExplorer: FilesExplorer,
         formatter: LogFormatter,
         config: LoggerConfig) {
        self.logSaver = logSaver
        self.logRetriever = logRetriever
        self.logFormatter = formatter
        self.filesExplorer = filesExplorer
        self.config = config
    }
    
    private func currentThreadId() -> String {
        var tid: __uint64_t = 0
        pthread_threadid_np(nil, &tid)
        return String(format: "thread=%#08x", tid)
    }
    
    private func currentThreadLabel() -> String {
        if Thread.isMainThread { return "main" }

        if OperationQueue.current != nil {
            return currentThreadId()
        } else if let queueName = String(validatingUTF8: __dispatch_queue_get_label(nil)) {
            return queueName.isEmpty ? currentThreadId() : queueName
        }

        return currentThreadId()
    }
}

// MARK: - Logger
extension LoggerImpl: Logger {
    func log(type: LogEventType, message: String, params: [String: Any]?, tag: String?) {
        let thread = currentThreadLabel()
        let date = Date()

        queue.addOperation { [weak self] in
            guard let self = self else { return }
            
            let log = self.logFormatter.formatLog(
                type: type,
                date: date,
                threadLabel: thread,
                message: message,
                params: params, tag: tag)
            
            self.logSaver.saveLog(log)
        }
    }
    
    func logs(from startDate: Date, to endDate: Date) -> Data {
        var result = Data()

        let operation = BlockOperation { [weak self] in
            guard let self = self else { return }
            
            let encoding = self.config.encoding.stringEncoding
            let string = self.logRetriever.logs(from: startDate, to: endDate)
            result = string.data(using: encoding) ?? Data()
        }

        queue.addOperations([operation], waitUntilFinished: true)
          
        return result
    }
    
    func logFiles() -> [LogFile] {
        var result = [LogFile]()
        
        let operation = BlockOperation { [weak self] in
            guard let logger = self else { return }
            
            result = logger.filesExplorer.logFiles()
        }
        
        queue.addOperations([operation], waitUntilFinished: true)
        
        return result
    }
    
    func logsFolderPath() -> String {
        config.logsFolder
    }
}

//
//  LoggerUtils.swift
//  
//
//  Created by Volodymyr Kotsiubenko on 29/4/24.
//

import Foundation

public struct LoggerUtils {
    private let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    public var logsDirectoryPath: String {
        logger.logsFolderPath()
    }
    
    // MARK: - Log file
    /// Returns an array of existent LogFile objects using closure
    public func logFiles(completion: @escaping ([LogFile]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let result = logger.logFiles()
                .sorted(by: { $0.fileUrl.creation > $1.fileUrl.creation })
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    /// Returns an array of existent LogFile objects using async/await
    public func logFiles() async -> [LogFile] {
        let result = logger.logFiles()
            .sorted(by: { $0.fileUrl.creation > $1.fileUrl.creation })
        return result
    }
    
    /// Returns last LogFile objects using closure
    public func lastLogFile(completion: @escaping (LogFile?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let result = logger.logFiles()
                .sorted(by: { $0.fileUrl.creation > $1.fileUrl.creation })
                .first
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    /// Returns last LogFile objects using async/await
    public func lastLogFile() async -> LogFile? {
        let result = logger.logFiles()
            .sorted(by: { $0.fileUrl.creation > $1.fileUrl.creation })
            .first
        return result
    }
}

fileprivate extension URL {
    /// The time at which the resource was created.
    /// This key corresponds to an Date value, or nil if the volume doesn't support creation dates.
    /// A resource’s creationDateKey value should be less than or equal to the resource’s contentModificationDateKey and contentAccessDateKey values. Otherwise, the file system may change the creationDateKey to the lesser of those values.
    var creation: Date {
        (try? resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date()
    }
}

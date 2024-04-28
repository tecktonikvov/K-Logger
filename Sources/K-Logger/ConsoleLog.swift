//
//  ConsoleLog.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko on (31.01.22).
//

import OSLog

final class ConsoleLog {
    private init() {}
    
    static func debug(_ message: String, subsystem: String, category: String) {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .default, message)
    }
    
    static func info(_ message: String, subsystem: String, category: String) {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .info, message)
    }
    
    static func warning(_ message: String, subsystem: String, category: String) {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .error, message)
    }
    
    static func error(_ message: String, subsystem: String, category: String) {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .error, message)
    }
    
    static func critical(_ message: String, subsystem: String, category: String) {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .fault, message)
    }
    
    static func requestOut(_ message: String, subsystem: String, category: String) {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .default, message)
    }
    
    static func requestIn(_ message: String, subsystem: String, category: String) {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .default, message)
    }
}

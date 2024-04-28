//
//  Log.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko on (31.01.22).
//

import Foundation

final class Log {
    typealias LogData = [String: Any]
    
    // MARK: - Private
    private init() {
        logger = LoggerComposer.makeDiskLogger()
    }
    
    private static var shared = Log()
    
    private var logger: Logger
    
    static var logsDirectoryPath: String {
        shared.logger.logsFolderPath()
    }
    
    // MARK: - State
    /// Logs regular application state information
    static func state(_ message: String) {
        state(message, data: nil, module: nil)
    }
    
    /// Logs regular application state information with specifying data or module
    static func state(_ message: String, data: LogData?, module: String?) {
        log(.debug, message: message, data: data, module: module)
    }
    
    // MARK: - Warning
    static func warning(_ message: String) {
        warning(message, data: nil, module: nil)
    }
    
    static func warning(_ message: String, data: LogData? = nil, module: String?) {
        log(.warning, message: message, data: data, module: module)
    }
    
    // MARK: - Error
    static func error(_ message: String) {
        error(message, data: nil, module: nil)
    }
    
    static func error(_ message: String, data: LogData? = nil, module: String?) {
        log(.error, message: message, data: data, module: module)
    }
    
    // MARK: - Critical
    static func critical(_ message: String) {
        critical(message, data: nil, module: nil)
    }
    
    static func critical(_ message: String, data: LogData? = nil, module: String?) {
        log(.critical, message: message, data: data, module: module)
    }
    
    // MARK: - RequestOut
    static func requestOut(_ message: String) {
        log(.requestOut, message: message, data: nil, module: nil)
    }
    
    // MARK: - RequestIn
    static func requestIn(_ message: String, operationName: String, statusCode: Int) {
        var result: String {
            let message = "\(operationName), \(statusCode)\n  --->>  \(message)"
            return message
        }
        
        log(.requestIn, message: result, data: nil, module: nil)
    }
    
    // MARK: - Info
    static func info(_ message: String) {
        info(message, data: nil, module: nil)
    }
    
    static func info(_ message: String, data: LogData? = nil, module: String?) {
        log(.info, message: message, data: data, module: module)
    }
    
    private static func logToConsole(_ message: String, subsystem: String?, type: LogEventType) {
        let subsystem = subsystem ?? ""
        
        switch type {
        case .info:
            ConsoleLog.info(message, subsystem: subsystem, category: "Info")
        case .debug:
            ConsoleLog.debug(message, subsystem: subsystem, category: "Debug")
        case .warning:
            ConsoleLog.warning(message, subsystem: subsystem, category: "Warning")
        case .error:
            ConsoleLog.error(message, subsystem: subsystem, category: "Error")
        case .critical:
            ConsoleLog.critical(message, subsystem: subsystem, category: "Critical")
        case .user(let label):
            ConsoleLog.debug(message, subsystem: subsystem, category: label)
        case .requestOut:
            ConsoleLog.requestOut(message, subsystem: subsystem, category: "REQUEST OUT")
        case .requestIn:
            ConsoleLog.requestIn(message, subsystem: subsystem, category: "REQUEST IN")
        }
    }
    
    // MARK: - Log file
    static func lastLogFileUrl(completion: @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let result = shared.logger.logFiles()
                .sorted(by: { $0.fileUrl.creation > $1.fileUrl.creation })
                .first?.fileUrl
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Private
    private static func log(_ type: LogEventType, message: String, data: LogData?, module: String?) {
        if let data = data, let module = module {
            logToConsole("[\(module)] \(message) \(data)", subsystem: module, type: type)
        } else if let data = data {
            logToConsole("\(message) \(data)", subsystem: module, type: type)
        } else if let module = module {
            logToConsole("[\(module)] \(message)", subsystem: module, type: type)
        } else {
            logToConsole("\(message)", subsystem: module, type: type)
        }
        
        shared.logger.log(type: type, message: message, params: data, tag: module)
    }
}

extension Log {
    enum FlowAction {
        case `start`
        case `continue`
        case `release`
        case show(scene: String)
        case move(toFlow: Any.Type)
        case showed(vc: Any)
        case toRoot(closedVCs: [Any]?)
        case pop(closedVC: Any?)
        case dismiss
    }
    
    /// Logs  application flow state
    static func flow<T>(_ flow: T, _ message: String) {
        state("<\(String(describing: type(of: flow)))> \(message)", data: nil, module: "FLOW")
    }
    
    static func flow(flowName: String, _ message: String) {
        state("<\(flowName)> \(message)", data: nil, module: "FLOW")
    }
    
    static func flow<T>(_ flow: T, action: FlowAction) {
        let flowName = String(describing: type(of: flow))
        log(flowName: flowName, action: action)
    }
    
    static func flow(flowName: String, action: FlowAction) {
        log(flowName: flowName, action: action)
    }
    
    private static func log(flowName: String, action: FlowAction) {
        switch action {
        case .start:
            self.flow(flowName: flowName, "Start")
        case .continue:
            self.flow(flowName: flowName, "Continue")
        case .release:
            self.flow(flowName: flowName, "Release")
        case let .move(toFlow):
            self.flow(flowName: flowName, "Move to \(String(describing: toFlow))")
        case let .show(scene):
            self.flow(flowName: flowName, "Show scene: \(scene)")
        case let .showed(vc):
            let vcString = stringDescribing(vc.self)
            self.flow(flowName: flowName, "Top VC: <\(vcString)>")
        case let .toRoot(closedVCs):
            var closedVCsString: String {
                guard let closedVCs else { return "" }
                
                let vcs = closedVCs.map {
                    return stringDescribing($0)
                }
                                
                return vcs.joined(separator: ",")
            }
            self.flow(flowName: flowName, "Returned to root VC. Closed view controllers: <\(closedVCsString)>")
        case let .pop(closedVC):
            if let closedVC {
                self.flow(flowName: flowName, "View controller closed: <\(stringDescribing(closedVC.self))>")
            } else {
                self.flow(flowName: flowName, "View controller closed: <none>")
            }
        case .dismiss:
            self.flow(flowName: flowName, "Modal view controller dismissed")
        }
    }
    
    private static func stringDescribing(_ obj: Any) -> String {
        let result = String(describing: obj.self)
        
        if let dotIndex = result.firstIndex(of: ".") {
            let distance = result.distance(from: result.startIndex, to: dotIndex)
            return String(describing: result.dropFirst(distance + 1).dropLast(14))
        }
        
        return String(describing: result.dropLast(14))
    }
}

extension Log {
    static func user(_ message: String) {
        state(message, data: .none, module: "USER")
    }
    
    static func analytics(_ message: String) {
        state(message, data: .none, module: "ANALYTICS")
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

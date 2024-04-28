//
//  LogEventType.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (13.01.2022).

import Foundation

public enum LogEventType {
    case info
    case debug
    case warning
    case error
    case critical
    case requestOut
    case requestIn
    case user(label: String)
        
    var mark: String {
        switch self {
        case .info:
            return "I"
        case .debug:
            return "D"
        case .warning:
            return "W"
        case .error:
            return "E"
        case .critical:
            return "C"
        case .user(let label):
            return "U[\(label)]"
        case .requestOut:
            return "RO"
        case .requestIn:
            return "RI"
        }
    }
}

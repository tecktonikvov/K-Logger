//
//  LogsEncoding.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (01.02.2022).

import Foundation

enum LogsEncoding: String {
    case utf8 = "UTF-8"
    
    var stringEncoding: String.Encoding {
        switch self {
        case .utf8:
            return .utf8
        }
    }
}

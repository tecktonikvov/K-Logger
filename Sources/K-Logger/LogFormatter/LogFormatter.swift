//
//  LogFormatter.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (12.01.2022).

import Foundation

public protocol LogFormatter {
    func formatLog(type: LogEventType,
                   date: Date,
                   threadLabel: String,
                   message: String,
                   params: [String: Any]?,
                   tag: String?) -> String
}

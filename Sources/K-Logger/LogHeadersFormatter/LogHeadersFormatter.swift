//
//  LogHeadersFormatter.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (31.01.2022).

import Foundation

protocol LogHeadersFormatter {
    func formattedString(fileCreationDate: Date,
                         encoding: String,
                         loggerVersion: String,
                         fields: String) -> String
    func headersLinesCount() -> Int
}

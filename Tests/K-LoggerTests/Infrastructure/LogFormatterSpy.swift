//
//  LogFormatterSpy.swift
//  LoggerTests
//
//  Created by Volodymyr Kotsiubenko (04.02.2022).
//

import Foundation
@testable import K_Logger

final class LogFormatterSpy {
    private let formatter: LogExtractorFormatter
    
    init(logFormatter: LogExtractorFormatter) {
        self.formatter = logFormatter
    }
    
    // MARK: - Tests
    private(set) var stringDatesFromDateRequest: [String]?
}

// MARK: - LogExtractorFormatter
extension LogFormatterSpy: LogExtractorFormatter {
    var dateStringSize: Int {
        formatter.dateStringSize
    }
    
    func date(from date: String) -> Date? {
        stringDatesFromDateRequest?.append(date)
        
        return formatter.date(from: date)
    }
}

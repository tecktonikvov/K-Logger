//
//  LogExtractorSpy.swift
//  LoggerTests
//
//  Created by Volodymyr Kotsiubenko (08.02.2022).
//

import Foundation
@testable import K_Logger

final class LogExtractorSpy: SyncExecutable {
    var lock = DispatchSemaphore(value: 1)
    
    private let extractor: LogExtractor

    // MARK: - Init
    init(extractor: LogExtractor) {
        self.extractor = extractor
    }
    
    // MARK: - Tests
    private(set) var datesFormExtractContentRequest = [Date: Date]()
    private(set) var returnedResult = ""
}

// MARK: - LogExtractor
extension LogExtractorSpy: LogExtractor {
    func extractContent(from startDate: Date, to endDate: Date) -> String {
        var result = ""
        
        sync {
            datesFormExtractContentRequest[startDate] = endDate
            result = extractor.extractContent(from: startDate, to: endDate)
            returnedResult = result
        }
        
        return result
    }
}

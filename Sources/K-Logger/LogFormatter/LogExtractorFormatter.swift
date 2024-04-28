//
//  LogFormatterExtractorInterface.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (03.02.2022).

import Foundation

protocol LogExtractorFormatter {
    var dateStringSize: Int { get }
    
    func date(from date: String) -> Date?
}

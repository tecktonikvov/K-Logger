//
//  LogExtractor.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (03.02.2022).

import Foundation

protocol LogExtractor {
    func extractContent(from startDate: Date, to endDate: Date) -> String
}

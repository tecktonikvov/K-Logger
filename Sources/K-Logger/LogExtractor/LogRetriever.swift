//
//  LogRetriever.swift
//  LoggerTests
//
//  Created by Volodymyr Kotsiubenko (10.02.2022).

import Foundation

protocol LogRetriever {
    func logs(from fromDate: Date, to toDate: Date) -> String
}

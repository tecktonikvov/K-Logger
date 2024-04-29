//
//  LineReader.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (02.02.2022).

import Foundation

protocol LineReader {
    var nextLine: String? { get }
}

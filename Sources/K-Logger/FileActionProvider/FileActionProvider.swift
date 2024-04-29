//
//  FileActionProvider.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (13.01.2022).

import Foundation

protocol FileActionProvider {
    func actionForLog(ofSize recordSize: UInt, using fileMetas: [FileMeta]) -> FileAction
}

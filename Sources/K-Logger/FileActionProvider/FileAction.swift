//
//  FileAction.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (17.01.2022).

import Foundation

enum FileAction {
    case create(fileName: String)
    case write(file: FileMeta)
    case rotation(dropFile: FileMeta, newFileName: String)
    case skip
}

// MARK: - Equatable
extension FileAction: Equatable {
    static func == (lhs: FileAction, rhs: FileAction) -> Bool {
        switch (lhs, rhs) {
        case let ((.create(lhsNewFileName), .create(rhsNewFileName))):
            return lhsNewFileName == rhsNewFileName
        case let (.write(lhsFileMeta), .write(rhsFileMeta)):
            return lhsFileMeta.url == rhsFileMeta.url
        case let (.rotation(lhsRotationDropFileMeta, lhsRotationNewFileName), .rotation(rhsRotationDropFileMeta, rhsRotationNewFileName)):
            return lhsRotationDropFileMeta.url == rhsRotationDropFileMeta.url &&
            lhsRotationNewFileName == rhsRotationNewFileName
        case (.skip, .skip):
            return true
        default:
            return false
        }
    }
}

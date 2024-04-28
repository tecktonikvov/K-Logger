//
//  FilesExplorer.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (18/2/22).

import Foundation

protocol FilesExplorer {
    func logFiles() -> [LogFile]
}

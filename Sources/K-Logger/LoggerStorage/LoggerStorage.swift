//
//  LoggerStorage.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (21.01.2022).

import Foundation

protocol LoggerStorage {
    func metaForAllFiles() -> [FileMeta]
    func log(fromFile file: FileMeta, offset: UInt) -> String
    func saveLog(_ log: String, to file: FileMeta)
    func deleteFile(_ file: FileMeta)
    func createFile(withName fileName: String) throws -> FileMeta
    func logSize(_ log: String) -> UInt
    func currentFileMeta() -> FileMeta?
    func readerFor(file: FileMeta) -> LineReader?
    func logFiles() -> [LogFile]
}

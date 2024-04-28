//
//  LoggerFileStorage.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (28.01.2022).

import Foundation

protocol LoggerFileStorage: FileAttributeLoader {
    func createFile(atPath path: String)
    func deleteFile(atPath path: String)
    func filesNames(atPath path: String) -> [String]
    func contents(ofFileAtPath path: String, encoding: String.Encoding) -> String?
    func createLogsFolder(atPath path: String)
    func files(inDirectory path: String) -> [String]
}

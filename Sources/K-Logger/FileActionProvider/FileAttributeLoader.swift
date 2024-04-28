//
//  FileAttributeLoader.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (19.01.2022).

import Foundation

protocol FileAttributeLoader {
    func fileAttributes(atUrl url: URL) -> [FileAttributeKey: Any]?
}

//
//  LogFile.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (18/2/22).

import Foundation

public struct LogFile {
    let fileUrl: URL
    
    var content: String {
        let text = try? String(contentsOf: fileUrl, encoding: .utf8)
        return text ?? ""
    }
}

//
//  LineReaderImpl.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (02.02.2022).

import Foundation

final class LineReaderImpl {
    private let file: UnsafeMutablePointer<FILE>
    
    init?(path: String) {
        guard let file = fopen(path, "r") else { return nil }
        self.file = file
    }
    
    deinit {
        fclose(file)
    }
}

// MARK: - LineReader
extension LineReaderImpl: LineReader {
    var nextLine: String? {
        var line: UnsafeMutablePointer<CChar>?
        var lineСap = 0
        
        defer { free(line) }
        
        let status = getline(&line, &lineСap, file)
        guard status > 0, let line = line else { return nil }
        
        return String(cString: line)
    }
}

// MARK: - Sequence
extension LineReaderImpl: Sequence {
    func makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            return self.nextLine
        }
    }
}

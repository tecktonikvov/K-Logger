//
//  ArrayExtension.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (16/2/22).

import Foundation

extension Array where Element == FileMeta {
    var unique: [FileMeta] {
        var result = [FileMeta]()

        for meta in self {
            if !result.contains(where: { $0.url == meta.url }) {
                result.append(meta)
            }
        }

        return result
    }
}

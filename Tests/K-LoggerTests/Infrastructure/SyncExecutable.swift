//
//  SyncExecutable.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (31.01.2022).
//

import Foundation

protocol SyncExecutable {
    var lock: DispatchSemaphore { get }
    
    func sync(_ code: () -> Void)
}

// MARK: - Protocol Extension
extension SyncExecutable {
    func sync(_ code: () -> Void) {
        lock.wait()
        code()
        lock.signal()
    }
}

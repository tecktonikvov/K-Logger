//
//  XCTestCase+Extension.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (02.02.2022).
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject,
                             file: StaticString = #filePath,
                             line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.",
                         file: file,
                         line: line)
        }
    }
}

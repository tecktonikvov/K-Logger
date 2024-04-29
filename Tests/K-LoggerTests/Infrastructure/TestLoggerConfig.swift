//
//  TestLoggerConfig.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (1/3/22).
//

import Foundation
@testable import K_Logger

final class TestLoggerConfig: LoggerConfig {
    private let baseConfig: LoggerConfig
    private let slash: String
    private let fakeCurrentDate: Date?
    
    init(baseConfig: LoggerConfig, includeSlash: Bool, fakeCurrentDate: Date? = nil) {
        self.slash = includeSlash ? "/" : ""
        self.baseConfig = baseConfig
        self.fakeCurrentDate = fakeCurrentDate
    }
    
    lazy var calendar = baseConfig.calendar
    lazy var loggerVersion = baseConfig.loggerVersion
    lazy var fileExtension = baseConfig.fileExtension
    lazy var encoding: LogsEncoding = baseConfig.encoding
    lazy var currentDate: Date = fakeCurrentDate ?? baseConfig.currentDate
    lazy var fileNameFormat = baseConfig.fileNameFormat
    lazy var logDateFormat = baseConfig.logDateFormat
    lazy var headersDateFormat = baseConfig.headersDateFormat
    lazy var fileNamePrefix = baseConfig.fileNamePrefix
    lazy var timeZone = baseConfig.timeZone
    lazy var logsFolder = baseConfig.logsFolder + slash
    lazy var locale = baseConfig.locale
    lazy var paramsPrefix = baseConfig.paramsPrefix
    lazy var fields = baseConfig.fields
    lazy var encodingHeader = baseConfig.encodingHeader
    lazy var versionHeader = baseConfig.versionHeader
    lazy var dateHeader = baseConfig.dateHeader
    lazy var fieldsHeader = baseConfig.fieldsHeader
    
    func fullFileName(fromFileName fileName: String) -> String {
        baseConfig.fullFileName(fromFileName: fileName)
    }
}

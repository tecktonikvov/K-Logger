//
//  LogFormatterImpl.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (12.01.2022).

import Foundation

fileprivate protocol FloatingPointNumbers {
    func toDecimal() -> Decimal
    
    var isNaN: Bool { get }
}

extension Double: FloatingPointNumbers {}
extension Float: FloatingPointNumbers {}

extension FloatingPointNumbers {
    func toDecimal() -> Decimal {
        Decimal(string: "\(self)") ?? Decimal()
    }
}

final class LogFormatterImpl {
    var eventType: LogEventType?
    var date: Date?
    var threadLabel: String?
    var message: String?
    var params: [String: Any]?
    var tag: String?
    
    let dateStringSize: Int
    
    private let formatter: DateFormatter
    private let config: LoggerConfig
    
    init(config: LoggerConfig) {
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = config.logDateFormat
            formatter.timeZone = TimeZone(abbreviation: config.timeZone)
            formatter.locale = Locale(identifier: config.locale)
            return formatter
        }()
        
        self.config = config
        self.formatter = formatter
        self.dateStringSize = formatter.string(from: Date()).count
    }
    
    func formatted() -> String {
        var components = [String]()
        
        if let date = date {
            components.append(formattedDate(date))
        }
        
        if let eventType = eventType {
            components.append(eventType.mark)
        }
        
        if threadLabel != nil || tag != nil {
            let threadAndTag = threadAndTag(threadLabel, tag)
            if !threadAndTag.isEmpty {
                components.append(threadAndTag)
            }
        }

        if let message = message {
            components.append(message)
        }

        if let params = params {
            components.append(formattedParams(params))
        }

        let formattedString = components.joined(separator: " ")
        
        return formattedString
    }
    
    // MARK: - Private
    private func formattedDate(_ date: Date) -> String {
        formatter.string(from: date)
    }
    
    private func threadAndTag(_ threadLabel: String?, _ tag: String?) -> String {
        var result = ""
        
        if let threadLabel = threadLabel {
            result.append(threadLabel)
            if tag != nil {
                result.append(", ")
            }
        }
        
        if let tag = tag {
            result.append("\(tag)")
        }
        
        return result == "" ? "" : "[\(result)]"
    }
    
    private func formattedParams(_ params: [String: Any]) -> String {
        var result = config.paramsPrefix
        
        let paramsString = convertToJsonString(params)
        result.append(paramsString)
        
        return result
    }
    
    private func convertToJsonString(_ dict: [String: Any]) -> String {
        let preparedDict = convertFloatingPointNumbersToDecimalIfNeeded(dict)
        if let theJSONData = try? JSONSerialization.data(withJSONObject: preparedDict, options: [.sortedKeys]) {
            return String(data: theJSONData, encoding: config.encoding.stringEncoding) ?? ""
        }
        return ""
    }
    
    private func convertFloatingPointNumbersToDecimalIfNeeded(_ dict: [String: Any]) -> [String: Any] {
        var result = [String: Any]()
        for (k, v) in dict {
            result[k] = convert(v)
        }
        return result
    }
    
    private func convert(_ element: Any) -> Any {
        switch element {
        case let array as [Any]:
            var result = [Any]()
            
            for item in array {
                result.append(convert(item))
            }
            
            return result

        case let dict as [String: Any]:
            var result = [String: Any]()
            
            for (k, v) in dict {
                result[k] = convert(v)
            }
            
            return result
            
        case let number as FloatingPointNumbers where number.isNaN:
            return "NaN"
            
        case let number as FloatingPointNumbers:
            return number.toDecimal()
            
        default:
            return element
        }
    }
}

// MARK: - LogFormatter
extension LogFormatterImpl: LogFormatter {
    /// Not thread safe! Manage multithreading in higher level objects.
    func formatLog(type: LogEventType,
                          date: Date,
                          threadLabel: String,
                          message: String,
                          params: [String: Any]?,
                          tag: String?) -> String {
        self.eventType = type
        self.date = date
        self.threadLabel = threadLabel
        self.message = message
        self.params = params
        self.tag = tag
                
        return formatted()
    }
}

// MARK: - LogExtractorFormatter
extension LogFormatterImpl: LogExtractorFormatter {
    func date(from date: String) -> Date? {
        formatter.date(from: date)
    }
}

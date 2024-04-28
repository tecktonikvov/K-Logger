//
//  Date+Extension.swift
//  K-Logger
//
//  Created by Volodymyr Kotsiubenko (16/2/22).

//

import Foundation

extension Date {
    static func dayBefore(usingCalendar calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }
    
    static func twoDaysBefore(usingCalendar calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date()
    }
}

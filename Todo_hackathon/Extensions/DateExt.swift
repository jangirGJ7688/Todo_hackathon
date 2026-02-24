//
//  DateExt.swift
//  Todo_hackathon
//
//  Created by Ganpat Jangir on 23/02/26.
//

import Foundation

extension Date {
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var startOfTomorrow: Date {
        Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: startOfToday
        )!
    }
}

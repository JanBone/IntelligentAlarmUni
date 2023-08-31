//
//  DaysObject.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 29/06/2023.
//

import Foundation
import SwiftUI


struct ItemDay: Identifiable, Hashable, Codable {
    var id = UUID()
    var selected = false
    var itemText: String
    var interValue: Int
    var itemLetter: String
    var isWeekend: Bool
}

class DaysOfTheWeekManager: ObservableObject {
    @Published var days = [
        ItemDay(selected: false, itemText: "Monday", interValue: 2, itemLetter: "Mon", isWeekend: false),
        ItemDay(selected: false, itemText: "Tuesday", interValue: 3, itemLetter: "Tue", isWeekend: false),
        ItemDay(selected: false, itemText: "Wednesday", interValue: 4, itemLetter: "Wed", isWeekend: false),
        ItemDay(selected: false, itemText: "Thursday", interValue: 5, itemLetter: "Thu", isWeekend: false),
        ItemDay(selected: false, itemText: "Friday", interValue: 6, itemLetter: "Fri", isWeekend: false),
        ItemDay(selected: false, itemText: "Saturday", interValue: 7, itemLetter: "Sat", isWeekend: true),
        ItemDay(selected: false, itemText: "Sunday", interValue: 1, itemLetter: "Sun", isWeekend: true)
    ]
}


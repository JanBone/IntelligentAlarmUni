//
//  alarmObject.swift
//  Intelligent Alarm
//
//  Created by Katia on 24/04/2022.
//

import SwiftUI

class AlarmObject: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var isActive: Bool
    var hour: Int
    var minute: Int
    var snooze: Int
    var repeatList: [ItemDay]
    var repeat_alarm: Bool
    private var alarmsIds: [String]
    var notificationObjects : [NotificationObject]
    var isDeleted : Bool
    var firstAlarmWeekDay : Int
    var missionName : Int
    var difficulty : Int
    var numberOfProblems : Int
    var alarmSound  : Int
    var isSnoozer  : Bool
    var originalAlarmId : UUID?
    
    init(isActive: Bool, hour: Int, minute: Int, repeatList: [ItemDay], snooze: Int, repeat_alarm: Bool, difficulty : Int, missionName : Int, numberOfProblems : Int, alarmSound : Int, notifications : [NotificationObject],  firstAlarmWeekDay : Int, isSnoozer : Bool, originalAlarmId : UUID?) {
        self.id = UUID()
        self.isActive = isActive
        self.hour = hour
        self.minute = minute
        self.repeatList = repeatList
        self.snooze = snooze
        self.repeat_alarm = repeat_alarm
        self.alarmsIds = []
        self.notificationObjects = notifications
        self.isDeleted = false
        self.firstAlarmWeekDay = 0
        self.difficulty = difficulty
        self.missionName = missionName
        self.numberOfProblems = numberOfProblems
        self.alarmSound = alarmSound
        self.firstAlarmWeekDay = firstAlarmWeekDay
        self.isSnoozer = isSnoozer
        self.originalAlarmId = originalAlarmId
    }
    
    func findNextDay() -> Int{
        let calendar = Calendar.current
        let date = Date()
        let components = calendar.dateComponents([.weekday], from: date)
        let dayOfTheWeek = components.weekday!
        var min = 10
        var isEmpty = true
        for day in self.repeatList{
            if day.selected && day.interValue >= dayOfTheWeek{
                if day.interValue < min{
                    min = day.interValue
                }
            }
            if day.selected{
                isEmpty = false
            }
        }
        if isEmpty{
            if isToday(){
                return dayOfTheWeek
            }
            else{
                return (dayOfTheWeek == 7) ? 1 : (dayOfTheWeek + 1)
            }
        }
        if min == 10{
            return 1
        }
        return min
        
    }
    
    func setAsDeleted(){
        self.isDeleted = true
    }
    
    func isToday() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(in: TimeZone.current, from: now)
        
        if let currentHour = components.hour, let currentMinute = components.minute {
            
            if hour > currentHour || (self.hour == currentHour && self.minute > currentMinute) {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    
    static func == (lhs: AlarmObject, rhs: AlarmObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func removeAllNotifications(){
        for notification in notificationObjects{
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id])
            
        }
    }
    
    func timeUntilNextAlarm(nextAlarmTime: Date) -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second], from: currentDate, to: nextAlarmTime)
        
        guard let seconds = components.second else {
            return 0
        }
        return max(seconds, 0)
    }
    
    func toDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .weekOfMonth], from: now)
        components.weekday = findNextDay()
        components.hour = self.hour
        components.minute = self.minute
        guard let date = calendar.date(from: components) else {
            return now
        }
        if date < now {
            guard let new_date = Calendar.current.date(byAdding: .day, value: 7, to: date)
            else {
                return now
            }
            return new_date
        }
        return date
    }
    
    
    
    
}

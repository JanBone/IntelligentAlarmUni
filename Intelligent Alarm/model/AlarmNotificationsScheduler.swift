//
//  AlarmNotificationsScheduler.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 31/07/2023.
//

import Foundation
import SwiftUI
import UserNotifications


func setAlarm(repeat_alarm: Bool, repeatList: [ItemDay], hour: Int, minute: Int) -> [NotificationObject]{
    var notifications: [NotificationObject] = []
    let semaphore = DispatchSemaphore(value: 0)
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { (granted, error) in
        if granted {
            let content = createNotificationContent()
            if repeat_alarm {
                notifications = scheduleRepeatAlarms(content: content, repeatList: repeatList, hour: minute, minute: hour, repeat_alarm: repeat_alarm)
            } else {
                notifications = scheduleSingleAlarm(content: content, hour: hour, minute: minute, repeat_alarm: repeat_alarm)
            }
        }
        semaphore.signal() 
    }
    _ = semaphore.wait(timeout: .distantFuture)
    return notifications
}

private func scheduleRepeatAlarms(content: UNMutableNotificationContent, repeatList : [ItemDay], hour :Int, minute: Int, repeat_alarm: Bool) -> [NotificationObject] {
    var notificationObjects : [NotificationObject] = []
    let center = UNUserNotificationCenter.current()
    for day in repeatList {
        if day.selected {
            let trigger = createNotificationTrigger(dayOfTheWeek: 1, repeatAlarm: true, hour: hour, minute: minute)
            let identifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
            let notificationObject = NotificationObject(id: identifier, dayOfTheWeek: day.interValue, hour: hour, minute: minute, repeat_notification: repeat_alarm)
            notificationObjects.append(notificationObject)
           
        }
    }
    return notificationObjects
}
func isToday2(hour : Int, minute : Int) -> Bool {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents(in: TimeZone.current, from: now)
    if let currentHour = components.hour, let currentMinute = components.minute {
        if hour > currentHour || (hour == currentHour && minute > currentMinute) {
            return true
        } else {
            return false
        }
    }
    return true
}
private func scheduleSingleAlarm(content: UNMutableNotificationContent, hour : Int, minute : Int, repeat_alarm : Bool) -> [NotificationObject]  {
    var notificationObjects : [NotificationObject] = []
    let center = UNUserNotificationCenter.current()
    let isTodayAlarm = isToday2(hour: hour, minute: minute)
    
    let calendar = Calendar.current
    let date = Date()
    let components = calendar.dateComponents([.weekday], from: date)
    let dayOfTheWeek = components.weekday!
    let nextDay = (dayOfTheWeek == 7) ? 1 : (dayOfTheWeek + 1)
    let trigger = isTodayAlarm ? createNotificationTrigger(dayOfTheWeek: dayOfTheWeek, repeatAlarm: false, hour : hour, minute : minute) : createNotificationTrigger(dayOfTheWeek: nextDay, repeatAlarm: false, hour : hour, minute : minute)
    let identifier = UUID().uuidString
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    center.add(request)
    var notificationObject = isTodayAlarm ? NotificationObject(id: identifier, dayOfTheWeek: dayOfTheWeek, hour: hour, minute: minute, repeat_notification: repeat_alarm) : NotificationObject(id: identifier, dayOfTheWeek: nextDay, hour: hour, minute: minute, repeat_notification: repeat_alarm)
    notificationObjects.append(notificationObject)
    return notificationObjects
}

private func createNotificationContent() -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "Alarm"
    content.body = "Your alarm is ringing!"
    content.sound = UNNotificationSound.defaultCritical
    return content
}

private func createNotificationTrigger(dayOfTheWeek: Int, repeatAlarm: Bool, hour : Int, minute : Int) -> UNCalendarNotificationTrigger {
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.weekday = dayOfTheWeek
    return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeatAlarm)
}

func getPendingNotification() {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { (requests) in
        for request in requests {
            print("\(request.trigger) : \(request.content.title)")
        }
    }
}


func snoozeAlarmNotification(snoozeTime  :  Int, snoozeDate : Date,  hour : Int, minute : Int, dayOfTheWeek : Int) -> NotificationObject{
    let content = UNMutableNotificationContent()
        content.title = "Snoozed alarm"
        content.body = "Turn off your alarm"
        content.sound = UNNotificationSound.default
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: snoozeDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    
        let notificationObject = NotificationObject(id: identifier, dayOfTheWeek: dayOfTheWeek, hour: hour, minute: minute, repeat_notification: false)
        return notificationObject
}

func snoozeAlarmFunc(originalAlarm : AlarmObject?, alarmRightNow : Bool) -> AlarmObject?{
    var snoozeTime = originalAlarm?.snooze
    let futureDate = Date()
    let currentDate = Date()
    var dateComponents = DateComponents()
    if !alarmRightNow{
        
        dateComponents.minute = snoozeTime
    }
    else{
        dateComponents.second = 5
    }
    
    guard let futureDate = Calendar.current.date(byAdding: dateComponents, to: currentDate) else {
        fatalError("Error adding  minutes to the current date.")}
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: futureDate)
    let minute = calendar.component(.minute, from: futureDate)
    let dayOfTheWeek = calendar.component(.weekday, from: futureDate)
    let notfitication = snoozeAlarmNotification(snoozeTime: snoozeTime ?? Int.max, snoozeDate: futureDate, hour: hour, minute: minute, dayOfTheWeek: dayOfTheWeek)

    var daysManager = DaysOfTheWeekManager().days
        let newAlarm = AlarmObject(
            isActive: true,
            hour: hour,
            minute: minute,
            repeatList: daysManager,
            snooze: snoozeTime ?? Int.max,
            repeat_alarm: false,
            difficulty: originalAlarm?.difficulty ?? 1,
            missionName: originalAlarm?.missionName ?? 1,
            numberOfProblems : originalAlarm?.numberOfProblems ?? 1,
            alarmSound: originalAlarm?.alarmSound ?? 1,
            notifications: [notfitication],
            firstAlarmWeekDay: dayOfTheWeek,
            isSnoozer: true,
            originalAlarmId: originalAlarm?.id
        )
        return newAlarm
}

func setFirstAlarmDay(hour : Int, minute : Int) -> Int{
    let calendar = Calendar.current
    let date = Date()
    let components = calendar.dateComponents([.weekday], from: date)
    let dayOfTheWeek = components.weekday!
    if isToday(hour: hour, minute: minute){
        return dayOfTheWeek
    }
    else{
        return (dayOfTheWeek == 7) ? 1 : (dayOfTheWeek + 1)
    }
}

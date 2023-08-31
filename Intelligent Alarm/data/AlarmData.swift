//
//  AlarmData.swift
//  Intelligent Alarm
//
//  Created by Katia on 24/04/2022.
//
import Combine
import SwiftUI
import Foundation


final class AlarmData: ObservableObject{
    @Published var nextAlarmToRing : AlarmObject?
    @Published var timeUntilNextAlarm  = Int.max
    @Published var showWindow  = false
    @Published var alarmsList =  [AlarmObject]() {
        didSet {
            
            if let encoded = try? JSONEncoder().encode(alarmsList) {
                UserDefaults.standard.set(encoded, forKey: "Alarms")
            }
        }
    }
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Alarms") {
            if let decodedItems = try? JSONDecoder().decode([AlarmObject].self, from: savedItems) {
                alarmsList = decodedItems
                return
            }
        }
        
        alarmsList = []
    }
    func addAlarm(alarmObject: AlarmObject?){
        if alarmObject != nil{
        
            alarmsList.append(alarmObject!)
            sortAlarmList()
            findClosestAlarm()
        }
    }
    
    func editAlarm(idToFind: String){
        let uuid = UUID(uuidString: idToFind)
        let alarmObjectToEdit = alarmsList.first(where: { $0.id == uuid})
        alarmObjectToEdit?.removeAllNotifications()
    }
    func deleteAlarm(alarmObject: AlarmObject){
        if let index = alarmsList.firstIndex(of: alarmObject) {
            let alarmToRemove = alarmsList[index]
            alarmToRemove.setAsDeleted()
            alarmsList.remove(at: index)
        }
    }
    func remove(alarmObject: AlarmObject) {
        deleteAlarm(alarmObject: alarmObject)
        let possibleSnoozers = alarmsList.filter { $0.originalAlarmId == alarmObject.id }
        for snoozerAlarm in possibleSnoozers{
                    deleteAlarm(alarmObject: snoozerAlarm)
        }
        findClosestAlarm()
    }
    
    func findAlarmByID(idToFind: String) -> AlarmObject? {
        let uuid = UUID(uuidString: idToFind)
        return alarmsList.first(where: { $0.id == uuid})
    }
    
    func sortAlarmList(){
        alarmsList = alarmsList.sorted { $0.hour < $1.hour || ($0.hour == $1.hour && $0.minute < $1.minute) }
    }
    
    func findClosestAlarm() {
        let now = Date()
        let activeAlarms = alarmsList.filter { $0.isActive }
        let closestActiveAlarm : AlarmObject?
        var timeInSeconds  = 0
        if activeAlarms.count == 1{
            closestActiveAlarm = activeAlarms[0]
            timeInSeconds = (closestActiveAlarm?.timeUntilNextAlarm(nextAlarmTime: closestActiveAlarm!.toDate()))!
        }
        else{
            closestActiveAlarm = activeAlarms.min(by: { $0.toDate().timeIntervalSince(now) < $1.toDate().timeIntervalSince(now)}) ?? nil
            if closestActiveAlarm != nil{
              
                timeInSeconds = timeUntilNextAlarm(nextAlarmTime: closestActiveAlarm!.toDate())
        
            }
            else{
                timeInSeconds = 0
            }
        }
        self.timeUntilNextAlarm = timeInSeconds
        self.nextAlarmToRing = closestActiveAlarm
        
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
    
    func setNextAlarmToRing(alarmObject : AlarmObject){
        nextAlarmToRing = alarmObject
    }
    
    func updateAlarmToInactive(){
        let calendar = Calendar.current
        let date = Date()
        let components = calendar.dateComponents([.weekday], from: date)
        let dayOfTheWeek = components.weekday!
        for alarm in alarmsList {
            if alarm.isActive && alarm.firstAlarmWeekDay == dayOfTheWeek && !alarm.isToday() && !alarm.repeat_alarm{
                alarm.isActive = false
            }
        }
    }
    
    
}



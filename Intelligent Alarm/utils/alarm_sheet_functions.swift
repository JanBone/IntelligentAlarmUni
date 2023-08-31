//
//  alarm_sheet_functions.swift
//  Intelligent Alarm
//
//  Created by Katia on 22/03/2022.
//

import Foundation

func calculateTimeUntilNextAlarm(selectedHours: Int, selectedMinutes: Int, repeatDays: [ItemDay]) -> String {
    let calendar = Calendar.current
    
    let currentDate = Date()
    let currentHours = calendar.component(.hour, from: currentDate)
    let currentMinutes = calendar.component(.minute, from: currentDate)
    let selectedSecond = calendar.component(.second, from: Date())
    let weekday = calendar.component(.weekday, from: currentDate)
    
    var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
    dateComponents.hour = selectedHours
    dateComponents.minute = selectedMinutes
    dateComponents.second = selectedSecond
    var nextAlarmDate: Date? = calendar.date(from: dateComponents)
    let isRepeat = IsRepeatDays(daysList: repeatDays)
    
    var indexOfTheCurrentDay = repeatDays.firstIndex { $0.interValue == weekday}
    var nextAlarmDay = -1
    var isToday = false
    if isRepeat{
        for _ in 0...6{
            let nextDay = repeatDays[indexOfTheCurrentDay ?? 0]
            if nextDay.selected{
                if ((selectedHours > currentHours) || (selectedHours == currentHours && selectedMinutes >= currentMinutes)) && nextDay.interValue == weekday{
                    nextAlarmDay = nextDay.interValue
                    isToday = true
                    break
                }
                else{
                    if nextDay.interValue != weekday{
                        nextAlarmDay = nextDay.interValue
                        break
                    }
                    
                }
            }
            
            indexOfTheCurrentDay = ((indexOfTheCurrentDay ?? 0) + 1) % 7
        }
    }
    else{
        if ((selectedHours < currentHours) || (selectedHours == currentHours && selectedMinutes <= currentMinutes)) && !isRepeat{
            nextAlarmDate = calendar.date(byAdding: .day, value: 1, to: nextAlarmDate!)
        }
    }
    var differenceInDays = 0
    if isRepeat{
        if !isToday{
            if nextAlarmDay == -1 && isRepeat {
                differenceInDays = 6
            }
            else{
                differenceInDays = calculateDayDifference(day1: weekday, day2: nextAlarmDay)
            }
            
            nextAlarmDate = calendar.date(byAdding: .day, value: differenceInDays, to: nextAlarmDate!)
            
        }
        
    }
    
    let diffComponents = calendar.dateComponents([.day, .hour, .minute], from: Date(), to: nextAlarmDate!)
    
    var timeUntilNextAlarm = "Alarm will ring in "
    var stringIsTooLong = false
    var biggerThanZero = false
    if let day = diffComponents.day, day > 0 {
        if day > 0{
            stringIsTooLong = true
        }
        timeUntilNextAlarm += "\(day) day\(day > 1 ? "s" : ""), "
    }
    if let hour = diffComponents.hour, hour > 0 {
        biggerThanZero = true
        if !stringIsTooLong{
            timeUntilNextAlarm += "\(hour) hour\(hour > 1 ? "s" : ""), "
        }
        else{
            timeUntilNextAlarm += "\(hour) hour\(hour > 1 ? "s" : "")"
        }
    }
    if let minute = diffComponents.minute, minute > 0 {
        biggerThanZero = true
        if !stringIsTooLong{
            timeUntilNextAlarm += "\(minute) minute\(minute > 1 ? "s" : "")"
        }
    }
    if !biggerThanZero {
        return  "Alarm will ring in less than a minute"
    }
    return timeUntilNextAlarm
    
}
func generateItems(len : Int) -> [Int] {
    var items = [Int]()
    items.append(-1)
    for i in (0..<len-1).reversed() {
        items.append(i)
    }
    items.append(-1)
    return items
}

func IsRepeat(daysList : DaysOfTheWeekManager) ->  Bool{
    for day in daysList.days{
        if day.selected{
            return true
        }
    }
    return false
}

func IsRepeatDays(daysList : [ItemDay]) ->  Bool{
    for day in daysList{
        if day.selected{
            return true
        }
    }
    return false
}

func isToday(hour: Int, minute: Int) -> Bool {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents(in: TimeZone.current, from: now)
    
    if let currentHour = components.hour, let currentMinute = components.minute {
        if hour > currentHour || (hour == currentHour && minute > currentMinute) {
            return false
        } else {
            return true
        }
    }
    return true
}

func calculateDayDifference(day1: Int, day2: Int) -> Int {
    let numberOfDaysInWeek = 7
    
    var difference = day2 - day1
    if difference <= 0 {
        difference += numberOfDaysInWeek
    }
    
    return difference
}

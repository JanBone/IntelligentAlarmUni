//
//  NotificationObject.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 01/07/2023.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import AVFoundation
import UserNotifications

class NotificationObject: Identifiable, Hashable, Codable{
    
    static func == (lhs: NotificationObject, rhs: NotificationObject) -> Bool {
            return lhs.id == rhs.id
        }
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(dayOfTheWeek)
            hasher.combine(hour)
            hasher.combine(minute)
            hasher.combine(repeat_notification)
            hasher.combine(soundObjectId)
        }
    
    let id: String
    var dayOfTheWeek: Int
    var hour: Int
    var minute: Int
    var repeat_notification: Bool
    var soundObjectId: String
    init(id: String, dayOfTheWeek: Int, hour: Int, minute: Int, repeat_notification: Bool) {
        self.id = id
        self.dayOfTheWeek = dayOfTheWeek
        self.hour = hour
        self.minute = minute
        self.repeat_notification = repeat_notification
        self.soundObjectId = ""
    }
    

    func setIdOfSoundObject(Id : String){
        self.soundObjectId = Id
    }
}





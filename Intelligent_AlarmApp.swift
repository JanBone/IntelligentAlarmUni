//
//  Intelligent_AlarmApp.swift
//  Intelligent Alarm
//
//  Created by Katia on 16/03/2022.
//

import SwiftUI

@main
struct Intelligent_AlarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.alarmData ?? AlarmData())
                .environmentObject(appDelegate.alarmPlayer ?? AlarmPlayer(alarmData: appDelegate.alarmData ?? AlarmData()))
        }
    }
}


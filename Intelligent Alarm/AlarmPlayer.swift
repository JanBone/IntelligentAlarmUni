//
//  AlarmPlayer.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 23/07/2023.
//
import Combine
import Foundation
import UIKit
import UserNotifications
import AVFoundation

class AlarmPlayer : ObservableObject {
    private var audioPlayerAlarms: AVAudioPlayer?
    private var timer: Timer?
    var alarmData: AlarmData
    init(alarmData : AlarmData) {
        self.alarmData = alarmData
    }
    func playAlarmSound(timeIntervalUntilNextAlarm: Double) {
        if alarmData.nextAlarmToRing?.alarmSound != nil{
            let soundName =  selectSoundName(missionName: alarmData.nextAlarmToRing?.alarmSound ?? 1)
            guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
                return
            }
            do {
                audioPlayerAlarms = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayerAlarms?.numberOfLoops = -1
                timer = Timer.scheduledTimer(withTimeInterval: timeIntervalUntilNextAlarm, repeats: false) { [weak self] _ in
                    self?.alarmData.showWindow = true
                    self?.audioPlayerAlarms?.play()
                }
            }
            catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
            
        }
    }
    
    func stopAlarmSound() {
        audioPlayerAlarms?.stop()
    }
    func nullifyPlayer(){
        audioPlayerAlarms = nil
    }
    
    private func selectSoundName(missionName: Int) -> String {
        switch missionName {
        case 1:
            return "sunrise"
        case 2:
            return "serenity"
        case 3:
            return "emergency_alarm"
        default:
            return "Off"
        }
    }
    
}



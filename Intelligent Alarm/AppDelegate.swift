//
//  AppDelegate.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 29/06/2023.
//

import Foundation
import UIKit
import UserNotifications
import AVFoundation
import Combine



class AppDelegate: UIResponder, UIApplicationDelegate{
    private var audioPlayerSilence: AVAudioPlayer?
    var alarmData: AlarmData?
    var cancellables = Set<AnyCancellable>()
    var alarmPlayer : AlarmPlayer?
    var timer: Timer?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) ->
    Bool {
        alarmData = AlarmData()
        alarmPlayer = AlarmPlayer(alarmData : alarmData!)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
        playSilence()
        alarmData?.findClosestAlarm()
        observerNextAlarm(publisher: alarmData ?? nil)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        audioPlayerSilence?.play()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        audioPlayerSilence?.play()
    }
    
    
    func playSilence() {
        guard let soundURL = Bundle.main.url(forResource: "silence_track", withExtension: "mp3") else {
            print("Sound file not found.")
            return
        }
        do {
            audioPlayerSilence = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayerSilence?.prepareToPlay()
            audioPlayerSilence?.numberOfLoops = -1
            DispatchQueue.global().async { [self] in
                while true {
                    self.audioPlayerSilence?.play()
                    Thread.sleep(forTimeInterval: 1.0)
                    audioPlayerSilence?.stop()
                }
            }
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    func nextAlarmValueChanged(_ newValue: AlarmObject?) {
        alarmPlayer?.nullifyPlayer()
        if alarmData?.nextAlarmToRing != nil{
            alarmPlayer?.playAlarmSound(timeIntervalUntilNextAlarm: Double(alarmData?.timeUntilNextAlarm ?? Int.max))
        }
        
        
    }
    func observerNextAlarm(publisher: AlarmData?) {
        publisher?.$nextAlarmToRing
            .sink { newValue in
               
                self.nextAlarmValueChanged(newValue ?? nil)
            }
            .store(in: &cancellables)
    }
    
    
    
}





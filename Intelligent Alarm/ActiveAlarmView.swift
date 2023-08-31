//
//  ActiveAlarmView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 29/06/2023.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import AVFoundation


struct ActiveAlarmView: View {
    @State private var currentDate = Date()
    @EnvironmentObject var alarmData: AlarmData
    @EnvironmentObject var alarmPlayer: AlarmPlayer
    @State var alarmObject : AlarmObject?
    @State var openGame = false
    @State var difficulty = 2
    @State var numberProblems = 2
    @State var memoryGame = MemoryGameModel(roundNumber: 1, difficulty: 1)
    @State var shakeMission = ShakeCounter(shakeThreshold: 1, totalNumberOfShakes: 10)
    @State var memoryGameIsPresented: Bool = false
    @State var countingStepsIsPresented: Bool = false
    @State var shakesIsPresented: Bool = false
    @State var mathGameIsPresented: Bool = false
    @State var isPreview = false
    @State var shakeIntesityCalculated = 1.0
    @State var gameFinishedUnSuccesfully = false
    
    @State var currentStageOfTheGame = 0
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        ZStack{
            ZStack {
                Image("night_sky")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    VStack{
                        Text(formatDate(currentDate, style: .short))
                            .font(Font.custom("Poppins-SemiBold", size: 30))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    if alarmObject?.snooze != -1 {
                        Button(action: {
                            alarmData.showWindow = false
                            snoozeAlarm()
                        }) {
                            
                            Text("Snooze")
                                .font(Font.custom("Poppins-SemiBold", size: 20))
                                .frame(width: UIScreen.main.bounds.width / 2.5, height: UIScreen.main.bounds.height / 16)
                                .font(.headline)
                                .padding()
                                .background(Color.ui.SunflowerYellow)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    Button(action: {
                        stopAlarmSoundDismiss()
                        dismissAlarm()
                        
                    }) {
                        Text("Dismiss")
                            .font(Font.custom("Poppins-SemiBold", size: 20))
                            .frame(width: UIScreen.main.bounds.width / 2.5, height: UIScreen.main.bounds.height / 16)
                            .font(.headline)
                            .padding()
                            .background(Color.ui.deepRed)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    Spacer()
                }
                .padding()
                
            }
            
            Group {
                if memoryGameIsPresented {
                    MemoryGameView(game: memoryGame, showingMemoryGame: $memoryGameIsPresented, isPreview: $isPreview, gameFinishedSuccesfully: $gameFinishedUnSuccesfully)
                } else if countingStepsIsPresented {
                    CountingStepsView(totalNumberOfSteps: $numberProblems, isPreview: $isPreview, showingMissionView: $countingStepsIsPresented, gameFinishedSuccesfully: $gameFinishedUnSuccesfully)
                }
            }.frame(width: UIScreen.main.bounds.width / 1)
            Group {
                if mathGameIsPresented {
                    MathGameView(roundNumber: $numberProblems, difficulty: $difficulty, showPreview: $isPreview, showMathView: $mathGameIsPresented,  gameFinishedSuccesfully: $gameFinishedUnSuccesfully)
                    
                } else if shakesIsPresented {
                    shakeMissionView(shakeIntensity: $shakeIntesityCalculated, totalNumberOfShakes: $numberProblems, showingMissionView: $shakesIsPresented, isPreview: $isPreview, shakeCounter: $shakeMission, gameFinishedSuccesfully: $gameFinishedUnSuccesfully)
                }
                
                
            }.frame(width: UIScreen.main.bounds.width / 1)
        }.frame(width: UIScreen.main.bounds.width * 0.99)
            .onAppear {
                alarmObject = alarmData.nextAlarmToRing
                let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    currentDate = Date()
                }
                RunLoop.current.add(timer, forMode: .common)
            }
        
        
            .onChange(of: memoryGameIsPresented) { newValue in
                if !memoryGameIsPresented{
                    if !gameFinishedUnSuccesfully{
                        alarmPlayer.nullifyPlayer()
                        alarmData.showWindow = false
                    }
                    else{
                        alarmPlayer.nullifyPlayer()
                        startAlarmOnceAgain()
                    }
                }
            }
            .onChange(of: countingStepsIsPresented) { newValue in
                if !countingStepsIsPresented{
                    if !gameFinishedUnSuccesfully{
                        alarmPlayer.nullifyPlayer()
                        alarmData.showWindow = false
                    }
                    else{
                        alarmPlayer.nullifyPlayer()
                        startAlarmOnceAgain()
                    }
                }
            }
            .onChange(of: shakesIsPresented) { newValue in
                if !shakesIsPresented{
                    if !gameFinishedUnSuccesfully{
                        alarmPlayer.nullifyPlayer()
                        alarmData.showWindow = false
                    }
                    else{
                        alarmPlayer.nullifyPlayer()
                        startAlarmOnceAgain()
                    }
                }
            }
            .onChange(of: mathGameIsPresented ) { newValue in
                if !mathGameIsPresented{
                    if !gameFinishedUnSuccesfully{
                        alarmData.showWindow = false
                        alarmPlayer.nullifyPlayer()
                    }
                    else{
                        alarmPlayer.nullifyPlayer()
                        startAlarmOnceAgain()
                    }
                }
            }
        
    }
    func formatDate(_ date: Date, style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = style
        dateFormatter.timeStyle = style
        return dateFormatter.string(from: date)
    }
    
    func dismissAlarm(){
        if alarmObject != nil{
            difficulty = alarmObject?.difficulty == -1 ? 1 : alarmObject?.difficulty ?? 1
            numberProblems = alarmObject?.numberOfProblems == -1 ? 1 : alarmObject?.numberOfProblems ?? 1
            switch alarmObject?.missionName {
            case 1:
                memoryGame = MemoryGameModel(roundNumber: numberProblems, difficulty: difficulty)
                memoryGameIsPresented = true
            case 2:
                countingStepsIsPresented = true
            case 3:
                mathGameIsPresented = true
            case 4:
                shakeIntesityCalculated  = translateShakeIntensity(shakeIntensity: Double(difficulty))
                shakeMission = ShakeCounter(shakeThreshold: shakeIntesityCalculated, totalNumberOfShakes: numberProblems)
                shakesIsPresented = true
            default:
                stopAlarmSoundDismiss()
                alarmData.showWindow = false
            }
        }
    }
    func translateShakeIntensity(shakeIntensity : Double) -> Double{
        
        switch shakeIntensity {
        case -1:
            return 1
        case 1:
            return 2.5
        case 2:
            return 3.5
        default:
            return 1.5
        }
    }
    func stopAlarmSoundDismiss() {
        alarmPlayer.stopAlarmSound()
    }
    func startAlarmOnceAgain() {
        alarmPlayer.playAlarmSound(timeIntervalUntilNextAlarm: 1)
    }
    func snoozeAlarm(){

        let new_alarm = snoozeAlarmFunc(originalAlarm : alarmObject ?? nil, alarmRightNow: false)
        alarmData.addAlarm(alarmObject: new_alarm ?? nil)

      
    }
    
}

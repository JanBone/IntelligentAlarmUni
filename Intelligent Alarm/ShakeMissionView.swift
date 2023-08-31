//
//  ShakeMissionView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 26/06/2023.
//

import Foundation
import CoreMotion
import SwiftUI



struct shakeMissionView: View {
    @Binding var shakeIntensity: Double
    @Binding var totalNumberOfShakes: Int
    @Binding var showingMissionView: Bool
    @State private var timer: Timer?
    @State var currentNumberOfShakes = 0
    @State private var timeForTimer = 30.0
    @State private var timeRemaining: Float = 0.0
    @State private var totalTime: Float = 30.0
    @State var timeManager = TimerManager(totalTime: 30)
    @Binding var isPreview: Bool
    @Binding var shakeCounter : ShakeCounter
    @State var showEndOfTheGameText = false
    @Binding var gameFinishedSuccesfully : Bool
    var body: some View {
        ZStack {
            Spacer()
            
            VStack {
                TimerView(timerManager: timeManager)
                if showEndOfTheGameText{
                    Text("Success!")
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundColor(Color.ui.lightGreen)
                        .transition(.opacity)
                }
                Spacer()
                
                ShakeCounterView(shakeCounter: shakeCounter, shakeCount: $currentNumberOfShakes, shakeThreshold: $shakeIntensity, totalNumberOfShakes: $totalNumberOfShakes, timeManager: $timeManager, showView: $showingMissionView, showEndOfTheGameText: $showEndOfTheGameText, gameFinishedSuccesfully: $gameFinishedSuccesfully)
                
                Spacer()
                
            }
            VStack {
                if isPreview{
                    Spacer()
                    PreviewView(showingView: $showingMissionView)
                }
            }
        }
        .background(Color.ui.pewterWithOpacity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}




class ShakeCounter: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published  var shakeDone : Int
    @Published var ShakesLeft = Int.max
    @Published var gameFinished = false
    private var shakeThreshold  = 1.5
    private var totalNumberOfShakes : Int
    
    var shakeCount = 0
    
    init(shakeThreshold : Double, totalNumberOfShakes : Int) {
        self.shakeThreshold = shakeThreshold
        self.totalNumberOfShakes = totalNumberOfShakes
        self.ShakesLeft = totalNumberOfShakes
        self.shakeDone = 0
    }
    
    deinit {
        stopShakeDetection()
    }
    
    func getCount() -> Int {
        return shakeCount
    }
    
    func startShakeDetection() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
                if let error = error {
                    print("Accelerometer error: \(error)")
                    return
                }
                guard let accelerationVal = self, let acceleration = data?.acceleration else { return }
                let magnitude = sqrt(pow(acceleration.x, 1) + pow(acceleration.y, 1) + pow(acceleration.z, 1))
                if magnitude >= accelerationVal.shakeThreshold {
                    accelerationVal.shakeCount += 1
                    accelerationVal.shakeDone += 1
                    accelerationVal.numberOfShakesLeft()
                }
            }
        }
    }
    
    private func numberOfShakesLeft() {
        if totalNumberOfShakes -  shakeDone > 0{
            ShakesLeft = totalNumberOfShakes - shakeDone
        }
        else{
            stopShakeDetection()
            gameFinished = true
        }
        
    }
    
    func returnShakesLeft() -> Int {
        if self.totalNumberOfShakes > self.shakeCount{
            return Int(self.totalNumberOfShakes - shakeCount)
        }
        else{
            return 0
        }
    }
    
    private func stopShakeDetection() {
        motionManager.stopAccelerometerUpdates()
    }
    
    
}


struct ShakeCounterView: View {
    @ObservedObject  var shakeCounter : ShakeCounter
    @Binding var shakeCount: Int
    @State var  degreesAngle = 15.0
    @Binding var shakeThreshold : Double
    @Binding var totalNumberOfShakes : Int
    @Binding var timeManager : TimerManager
    @Binding var showView : Bool
    @Binding var showEndOfTheGameText : Bool
    @Binding var gameFinishedSuccesfully : Bool
    var body: some View {
        VStack {
            Text("\(shakeCounter.ShakesLeft)")
                .padding()
                .font(Font.custom("Poppins-Bold", size: 60))
        }
        .onChange(of: shakeCounter.ShakesLeft) { newValue in
            timeManager.restartTimer()
        }
        .onChange(of: shakeCounter.gameFinished) { newValue in
            timeManager.stopTimer()
            showEndOfTheGameText = true
            if newValue{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showView = false
                    gameFinishedSuccesfully = false
                }
            } 
        }
        .onChange(of: timeManager.timerFinished) { newValue in
            if newValue == true{
                timeManager.restartTimer()
                gameFinishedSuccesfully = true
                showView = false
                shakeCount = 0
            }
        }
        .onAppear {
            
            shakeCounter.startShakeDetection()
        }
        .frame(maxWidth: UIScreen.main.bounds.width / 2, maxHeight: UIScreen.main.bounds.width / 2)
        .background(Color.ui.scallopSeashellLight)
        .clipShape(Circle())
        
    }
}







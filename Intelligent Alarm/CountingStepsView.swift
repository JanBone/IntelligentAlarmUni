//
//  CountingStepsView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 25/06/2023.
//

import Foundation
import CoreMotion
import SwiftUI
import Combine

class StepCounter: ObservableObject {
    let pedometer = CMPedometer()
    @Published var steps: Int = 0
    var isCounting = false
    
    func startCounting() {
        isCounting = true
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.steps = Int(truncating: data.numberOfSteps)
                
            }
        }
    }
    
    func stopCounting() {
        isCounting = false
        pedometer.stopUpdates()
    }
}


struct HorizontalPickerWheel: View {
    @State private var selectedIndex = 1
    @Binding var currentNumberOfSteps: Int
    @Binding var totalNumberOfSteps: Int
    @State var oldNumberOfSteps = 0
    @Binding var timeManager : TimerManager
    @Binding var showView : Bool
    @Binding var gameFinishedSuccesfully : Bool
    private var items: [Int] {
        generateItems(len: totalNumberOfSteps + 2)
    }
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(max(0, selectedIndex - 1)...min(items.count - 1, selectedIndex + 1), id: \.self) { index in
                Text("\(items[index])").padding()
                    .font(Font.custom("Poppins-Bold", size:  35))
                    .foregroundColor(selectedIndex == index ? Color.ui.deepRed : Color.ui.darkGray)
                    .cornerRadius(15)
                    .opacity((index == selectedIndex - 1 || index == selectedIndex + 1) ? 0.5 : 1)
                    .background(selectedIndex == index ? Color.ui.scallopSeashellLight : Color.ui.pewter)
                    .cornerRadius(15)
                    .foregroundColor(selectedIndex == index ? Color.ui.darkGray : Color.ui.gray)
                    .frame( maxWidth: UIScreen.main.bounds.width / 3.5)
                    .shadow(color: Color.ui.pewter, radius: 7, x: 0, y: 2)
                    .opacity(index == 0 || index == items.count - 1 ? 0 : 1)
                    .scaleEffect(selectedIndex == index ? 2 : 1)
            }.padding()
        }
        .onChange(of: currentNumberOfSteps) { newValue in
            if currentNumberOfSteps <= totalNumberOfSteps {
                updateIndex(newIndex: currentNumberOfSteps + 1)
            } else {
                updateIndex(newIndex: items.count - 2)
            }
        }
        .onChange(of: timeManager.timerFinished) { newValue in
            if newValue{
                gameFinishedSuccesfully = true
                showView = false
            }
        }
    }
    
    private func updateIndex(newIndex: Int) {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 3)) {
            selectedIndex = newIndex
        }
    }
}


struct CountingStepsView: View {
    @Binding var totalNumberOfSteps: Int
    @State private var currentNumberOfSteps = 0
    @State private var timeRemaining: Float = 0.0
    @State private var totalTime: Float = 30.0
    @State var timerManager = TimerManager(totalTime: 30)
    @Binding var isPreview: Bool
    @Binding var showingMissionView: Bool
    @StateObject var stepCounter = StepCounter()
    @State var  gameFinished = false
    @Binding var gameFinishedSuccesfully : Bool
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                TimerView(timerManager: timerManager)
                
                if gameFinished{
                    Text("Success!")
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundColor(Color.ui.lightGreen)
                        .transition(.opacity)
                }
                Spacer()
                HorizontalPickerWheel(currentNumberOfSteps: $stepCounter.steps, totalNumberOfSteps: $totalNumberOfSteps, timeManager : $timerManager, showView: $showingMissionView, gameFinishedSuccesfully: $gameFinishedSuccesfully)
                Spacer()
                Image("walking_person")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 4)
                    .padding(.top, 10)
                Spacer()
            }
            VStack {
                Spacer()
                if isPreview{
                    PreviewView(showingView: $showingMissionView)
                }
                
            }
        }
        .onChange(of: stepCounter.steps) { newValue in
            if stepCounter.steps >= totalNumberOfSteps {
                stepCounter.stopCounting()
                timerManager.stopTimer()
                withAnimation{
                    gameFinished = true
                }
                gameFinishedSuccesfully = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showingMissionView = false
                }
            }
            else{
                timerManager.restartTimer()
            }
            
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ui.pewterWithOpacity)
        .onAppear {
            stepCounter.startCounting()
            timerManager.timeRemaining = totalTime
            if totalNumberOfSteps == -1{
                totalNumberOfSteps = 1
            }
        }
        .onChange(of: timerManager.timerFinished) { newValue in
            if newValue == true{
                restartGame()
            }
        }
        .onDisappear {
            stepCounter.stopCounting()
        }
    }
    
    func resetTimer() {
        timerManager.timeRemaining = totalTime
    }
    func restartGame(){
        timeRemaining = totalTime
        currentNumberOfSteps = 0
        timerManager.timerFinished = false
        timerManager.restartTimer()
    }
    
}

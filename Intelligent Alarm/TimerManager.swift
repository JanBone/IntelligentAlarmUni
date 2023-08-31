//
//  timerManager.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 28/06/2023.
//


import Foundation
import UIKit
import SwiftUI
import Combine


struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack {
            ProgressView(value: timerManager.timeRemaining, total: timerManager.totalTime)
                .frame(height: 40)
                .tint(Color.ui.deepRed)
                .padding()
                .scaleEffect(x: 1, y: 4, anchor: .center)
        }
        .onAppear {
            timerManager.startTimer()
        }
        .onDisappear {
            timerManager.stopTimer()
        }
    }
}

final class TimerManager: ObservableObject {
    @Published var timeRemaining: Float
    @Published var timerFinished = false
    var totalTime: Float
    private var timer: Timer?
    init(totalTime: Float) {
        self.timeRemaining = totalTime
        self.totalTime = totalTime
    }
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    func restartTimer() {
        timeRemaining = totalTime
        startTimer()
    }
    
    func startTimer() {
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.timeRemaining > 0 && !timerFinished{
                self.timeRemaining -= 1
                
            }
            else
            {
                self.stopTimer()
                DispatchQueue.main.async {
                    self.timerFinished = true
                }
                
            }
        }
        
    }
    
    
}

//
//  CountingStepsSettingsView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 26/06/2023.
//

import Foundation
import CoreMotion
import SwiftUI



struct ShakeSettingsMissionView: View {
    @Binding var showingShakeSettingsView : Bool
    @Binding var shakeTotalCount : Int
    @State var showingShakeView = false
    let numberOfStepsRange = 1...999
    @Binding var ShakeIntensity : Int
    @State var ShakeIntensity2  = 1
    @State var isPreview = false
    @Binding var missionName : Int
    @State var shakeIntensityCalculated = 1.0
    @State var shakeCounter = ShakeCounter(shakeThreshold: 1, totalNumberOfShakes: 20)
    @State var gameIsFinished = false
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                DifficultySlider(selectedDifficulty: $ShakeIntensity).padding()
                NumberOfProblemsPicker(numberOfProblems: $shakeTotalCount, problemRange: numberOfStepsRange, tagText: "shakes").padding()
                Spacer()
                HStack {
                    GameButtonsView(buttonText: "Cancel", function: cleanState)
                    PreviewButtonView(buttonText: "Preview", function: openPreviewGame)
                    GameButtonsView(buttonText: "Done", function: saveState)
                }
            }
            if showingShakeView{
                shakeMissionView(shakeIntensity: $shakeIntensityCalculated, totalNumberOfShakes: $shakeTotalCount, showingMissionView: $showingShakeView, isPreview: $isPreview, shakeCounter: $shakeCounter, gameFinishedSuccesfully: $gameIsFinished)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ui.pewterWithOpacity)
        .transition(.scale)
    }
    
    private func closeView() {
        withAnimation{
            showingShakeSettingsView = false
        }
        
    }
    func createShakeMission(){
        shakeIntensityCalculated = translateShakeIntensity(shakeIntensity: Double(ShakeIntensity))
        shakeCounter = ShakeCounter(shakeThreshold: shakeIntensityCalculated, totalNumberOfShakes:  shakeTotalCount)
    }
    
    private func saveState(){
        missionName = 4
        closeView()
    }
    private func openPreviewGame(){
        createShakeMission()
        withAnimation{
            isPreview = true
            shakeIntensityCalculated = translateShakeIntensity(shakeIntensity: Double(ShakeIntensity))
            showingShakeView = true
            
        }
    }
    
    func cleanState(){
        shakeTotalCount = -1
        ShakeIntensity = -1
        closeView()
        
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
    
    
}



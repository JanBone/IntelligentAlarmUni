//
//  MathGameSettingsView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 12/07/2023.
//


import Foundation
import SwiftUI

struct MathGameSettingsMissionView: View {
    @Binding var showingMathSettingsView : Bool
    @Binding var mathGameNumberOfProblems : Int
    @State var showingMathView = false
    let numberOfMathGameRoundRange = 1...999
    @Binding var mathGameDifficulty : Int
    @State var isPreview = false
    @Binding var missionName : Int
    @State var isGameFinishedSuccesfully = false
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                DifficultySlider(selectedDifficulty: $mathGameDifficulty).padding()
                
                NumberOfProblemsPicker(numberOfProblems: $mathGameNumberOfProblems, problemRange: numberOfMathGameRoundRange, tagText: "problems").padding()
                Spacer()
                HStack {
                    GameButtonsView(buttonText: "Cancel", function: cleanState)
                    PreviewButtonView(buttonText: "Preview", function: openPreviewGame)
                    GameButtonsView(buttonText: "Done", function: saveState)
                }
                
            }
            if showingMathView{
                MathGameView(roundNumber: $mathGameNumberOfProblems, difficulty: $mathGameDifficulty, showPreview: $isPreview, showMathView: $showingMathView, gameFinishedSuccesfully: $isGameFinishedSuccesfully)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ui.pewterWithOpacity)
        .transition(.scale)
    }
    
    private func closeView() {
        withAnimation{
            showingMathSettingsView = false
        }
        
    }
    private func openPreviewGame(){
        withAnimation{
            isPreview = true
            showingMathView = true
            
        }
    }
    private   func cleanState(){
        mathGameDifficulty = -1
        mathGameNumberOfProblems = -1
        missionName = -1
        closeView()
    }
    private func saveState(){
        missionName = 3
        closeView()
    }
    
}

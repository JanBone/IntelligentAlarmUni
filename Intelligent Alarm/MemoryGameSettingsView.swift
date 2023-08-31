//
//  MemoryGameSettingsView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 08/06/2023.
//

import Foundation
import SwiftUI



struct MemoryGameSettingsView: View {
    @Binding  var selectedRoundNumber : Int
    @Binding  var selectedDifficulty : Int
    @Binding var showingMemoryGameSettingsView : Bool
    let problemRange = 1...20
    @State private var difficulty: Double = 0.0
    @State var showingMemoryGame = false
    @State var isPreview = false
    @Binding var missionName : Int
    @State var game  = MemoryGameModel(roundNumber: 1, difficulty: 0)
    @State var isGameFinished = false
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                DifficultySlider(difficulty: difficulty, selectedDifficulty: $selectedDifficulty).padding()
                
                MemoryGameNumberOfRoundsPicker(numberOfRounds: $selectedRoundNumber, problemRange: problemRange).padding()
                Spacer()
                HStack {
                    GameButtonsView(buttonText: "Cancel", function: cleanState)
                    PreviewButtonView(buttonText: "Preview", function: openPreviewGame)
                    GameButtonsView(buttonText: "Done", function: saveState)
                }
                
            }
            if showingMemoryGame{
                
                MemoryGameView(game: game, showingMemoryGame: $showingMemoryGame, isPreview: $isPreview, gameFinishedSuccesfully: $isGameFinished)
                
            }
            
        }
        .background(Color.ui.pewterWithOpacity)
        .transition(.scale)
    }
    
    private func closeView() {
        withAnimation{
            showingMemoryGameSettingsView = false
        }
        
    }
    private func createGame(){
        game = MemoryGameModel(roundNumber: selectedRoundNumber, difficulty: selectedDifficulty + 1)
    }
    private func openPreviewGame(){
        createGame()
        withAnimation{
            isPreview = true
            showingMemoryGame = true
        }
    }
    func cleanState(){
        
        selectedDifficulty = -1
        selectedRoundNumber = -1
        missionName = -1
        closeView()
    }
    private func saveState(){
        missionName = 1
        closeView()
        
    }
    
    
}

struct DifficultySlider: View {
    @State var difficulty = 0.0
    @Binding var selectedDifficulty: Int
    private let difficultyLevels: Int = 3
    private let activeColor = Color.ui.SunflowerYellow
    private let inactiveColor = Color.ui.deepRed
    
    private func difficultyDescription() -> String {
        let descriptions = [ "Easy", "Medium", "Hard"]
        let index = Int(difficulty)
        guard index >= 0 && index < descriptions.count else {
            return "Unknown"
        }
        return descriptions[index]
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack {
                    Text("Choose Game Level")
                        .font(.custom("Poppins-Bold", size: 20))
                    
                    Text(difficultyDescription())
                        .font(.custom("Poppins-SemiBold", size: 20))
                        .padding()
                        .foregroundColor(Color.ui.darkGray)
                    
                    Slider(value: $difficulty, in: 0...Double(difficultyLevels - 1), step: 1)
                        .tint(Color.ui.deepRed)
                        .frame(width: 250)
                        .padding(.horizontal)
                        .foregroundColor(Color.ui.darkGray)
                        .overlay(
                            HStack(spacing: 0) {
                                ForEach(0..<difficultyLevels) { i in
                                    Circle()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(difficulty >= Double(i) ? activeColor : inactiveColor)
                                    
                                    if i < difficultyLevels - 1 {
                                        Spacer()
                                    }
                                }
                            }
                                .padding(.horizontal, 15)
                        )
                        .onChange(of: difficulty) { value in
                            selectedDifficulty = Int(round(value))
                        }
                }
                Spacer()
            }
            
            HStack {
                Text("Easy")
                Spacer()
                Text("Hard")
            }
            .font(.custom("Poppins-SemiBold", size: 15))
            .foregroundColor(Color.ui.darkGray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.ui.ivory)
        .cornerRadius(25)
        .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
        .frame(width: UIScreen.main.bounds.width * 0.9)
    }
}

struct MemoryGameNumberOfRoundsPicker: View {
    @Binding var numberOfRounds: Int
    var problemRange: ClosedRange<Int>
    var tagText = "rounds"
    var body: some View {
        VStack {
            Text("Choose number of rounds")
                .font(.custom("Poppins-Bold", size: 20))
            
            Picker(selection: $numberOfRounds, label: Text("Number of Problems")) {
                ForEach(problemRange, id: \.self) { number in
                    Text("\(number)")
                    
                        .font(.custom("Poppins-SemiBold", size: 23))
                        .foregroundColor(Color.ui.darkGray)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            .overlay(
                Text(tagText)
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(Color.ui.darkGray)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing),
                alignment: .trailing
            )
            
        }
        
        
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.ui.ivory)
        .cornerRadius(25)
        .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
        .frame(width: UIScreen.main.bounds.width * 0.9)
    }
}

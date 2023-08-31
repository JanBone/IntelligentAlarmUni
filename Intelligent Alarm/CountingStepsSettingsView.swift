//
//  CountingStepsSettingsView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 26/06/2023.
//

import Foundation
import CoreMotion
import SwiftUI



struct CountingStepsSettingsView: View {
    @Binding var showingCountingStepsSettingsView :Bool
    @Binding var numberOfSteps : Int
    @State var showingCountStepView = false
    let numberOfStepsRange = 1...999
    var showingMemoryGame = false
    @State var isPreview = false
    @Binding var missionName : Int
    @State var isGameFinished = false
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                NumberOfProblemsPicker(numberOfProblems: $numberOfSteps, problemRange: numberOfStepsRange, tagText: "steps")
                Spacer()
                HStack {
                    GameButtonsView(buttonText: "Cancel", function: cleanState)
                    PreviewButtonView(buttonText: "Preview", function: openPreviewGame)
                    GameButtonsView(buttonText: "Done", function: saveState)
                }
                
            }
            if showingCountStepView{
                CountingStepsView(totalNumberOfSteps: $numberOfSteps, isPreview: $isPreview, showingMissionView: $showingCountStepView, gameFinishedSuccesfully: $isGameFinished )
                
            }
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.ui.pewterWithOpacity)
            .transition(.scale)
        
    }
    
    private func closeView() {
        withAnimation{
            showingCountingStepsSettingsView = false
        }
        
    }
    private func openPreviewGame(){
        withAnimation{
            isPreview = true
            showingCountStepView = true
        }
    }
    private  func cleanState(){
        
        numberOfSteps = -1
        missionName = -1
        closeView()
    }
    private func saveState(){
        missionName = 2
        closeView()
    }
    
}


struct NumberOfProblemsPicker: View {
    @Binding var numberOfProblems: Int
    var problemRange: ClosedRange<Int>
    var tagText : String
    var body: some View {
        VStack {
            Text("Choose number of \(tagText)")
                .font(.custom("Poppins-Bold", size: 20))
            
            Picker(selection: $numberOfProblems, label: Text("Number of steps")) {
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



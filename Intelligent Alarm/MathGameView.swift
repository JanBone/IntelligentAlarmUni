//
//  MathGameView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 12/07/2023.
//

import Foundation
import SwiftUI


struct RoundCountMathView: View {
    @Binding var currentRound : Int
    @Binding var roundNumber : Int
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("Round count: ")
                    .foregroundColor(.black)
                Text("\(currentRound)")
                    .foregroundColor(.white)
                Text(":")
                    .foregroundColor(.white)
                Text("\(roundNumber)")
                    .foregroundColor(.white) // or another color if you like
            }

                .font(Font.custom("Poppins-SemiBold", size: 25))
                .foregroundColor(.white)
                .padding()
        }
        .padding()
        .frame(minWidth: 0,
               maxWidth: .infinity
        )
        .background(Color.ui.SunflowerYellow)
        .cornerRadius(15)
        .padding()
        .shadow(color: .gray, radius: 7, x: 0, y: 0)
    }
}

struct MathGameView: View {
    @State  var mathExample = MathExample(numberOfRounds: 1, difficulty: 0)
    @State var currentExample = Equation(text: "2+2=?", answer: 4)
    @State  var userAnswer = ""
    @State var currentRound = 1
    @Binding  var roundNumber : Int
    @Binding var difficulty : Int
    @State private var check = true
    @Binding  var showPreview : Bool
    @Binding var showMathView : Bool
    @State private var totalTime: Float = 30.0
    @State var timerManager = TimerManager(totalTime: 30)
    @State var gameFinished  = false
    @State var gameStarted = false
    @Binding var gameFinishedSuccesfully : Bool
    var body: some View {
        ZStack{
            VStack {
                TimerView(timerManager: timerManager)
                Spacer()
                RoundCountMathView(currentRound: $currentRound, roundNumber: $roundNumber)
                VStack {
                    Spacer()
                    
                    Text(currentExample.text)
                        .frame(width: UIScreen.main.bounds.width / 1.3)
                        .padding()
                        .background(Color.ui.scallopSeashell)
                        .clipShape(RoundedRectangle(cornerRadius: 15.0, style: .continuous))
                        .shadow(color: Color.ui.pewter, radius: 7, x: 0, y: 2)
                        .font(Font.custom("Poppins-SemiBold", size: 40))
                        .foregroundColor(Color.ui.darkGray)
                    Spacer()
                    TextField("Answer", text: $userAnswer)
                        .padding(.all, 20)
                        .font(Font.custom("Poppins-SemiBold", size: 15))
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .shadow(color: Color.ui.pewter, radius: 10, x: 0, y: 2)
                        .cornerRadius(10)
                    Spacer()
                }
                .onAppear(){
                    currentExample = mathExample.generateRandomExample()
                }
                .frame(width: UIScreen.main.bounds.width / 1.3, height: UIScreen.main.bounds.height / 3)
                
                Button(action: checkAnswer) {
                    Text("Submit")
                        .padding()
                        .background(Color.ui.pewter)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.ui.pewter, radius: 10, x: 0, y: 2)
                        .font(Font.custom("Poppins-SemiBold", size: 20))
                }
                
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.ui.pewterWithOpacity)
            VStack{
                if showPreview{
                    Spacer()
                    PreviewView(showingView: $showMathView)
                }
            }
        }
        .onAppear {
            mathExample = MathExample(numberOfRounds: roundNumber, difficulty: difficulty)
            timerManager.timeRemaining = totalTime
            if roundNumber == -1{
                roundNumber = 1
            }
        }
        .onChange(of: timerManager.timerFinished) { newValue in
            if newValue{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    gameFinishedSuccesfully = true
                    showMathView = false
                }
            }
        }
        
    }
    func resetTimer() {
        timerManager.timeRemaining = totalTime
    }
    func checkAnswer() {
        if let userInt = Int(userAnswer) {
            if userInt == currentExample.answer {
                currentRound += 1
                    currentExample = mathExample.generateRandomExample()
                    gameStarted = true
                    timerManager.restartTimer()
            }
            if currentRound == roundNumber  && currentRound != 1{
                gameFinished = true
            }
            if gameStarted && roundNumber == 1{
                gameFinished = true
            }
            
        }
        if gameFinished &&  currentRound == roundNumber + 1{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                gameFinishedSuccesfully = false
                showMathView = false
            }
            
        }
        userAnswer = ""
        
    }
}



struct Equation {
    let text: String
    let answer: Int
}

class MathExample {
    var currentRound : Int = 1
    var numberOfRounds : Int
    var firstRound = false
    var numberOfExamples : Int = 0
    var difficulty : Int
    init(numberOfRounds : Int, difficulty : Int) {
        self.difficulty = difficulty
        self.numberOfRounds = numberOfRounds
    }
    func generateRandomExample() -> Equation{
        var operand1 = Int.random(in: 1...10)
        var operand2 = Int.random(in: 1...10)
        var answer: Int
        var text: String
        switch self.difficulty {
        case 0:
            operand1 = Int.random(in: 1...10)
            operand2 = Int.random(in: 1...10)
            break
        case 1:
            operand1 = Int.random(in: 10...40)
            operand2 = Int.random(in: 10...40)
            break
        case 2:
            operand1 = Int.random(in: 100...350)
            operand2 = Int.random(in: 100...350)
            break
        default:
            operand1 = Int.random(in: 1...10)
            operand2 = Int.random(in: 1...10)
        }
        
        answer = operand1 + operand2
        text = "\(operand1) + \(operand2) = ?"
        return Equation(text: text, answer: answer)
    }
    
}



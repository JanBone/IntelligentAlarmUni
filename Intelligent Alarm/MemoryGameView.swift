//
//  MemoryGameView.swift
//  Intelligent Alarm
//
//  Created by Kate on 28/05/2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

struct Card: Hashable, Identifiable, Equatable {
    var isFaceUp = false
    let id: UUID
    var isSelected: Bool
    var imageName: String
    var cardColor: Color
    var isPictureCard: Bool
    
    init(id: UUID, isSelected: Bool) {
        self.id = id
        self.isFaceUp = false
        self.isSelected = isSelected
        self.imageName = ""
        self.cardColor = Color.ui.scallopSeashellLight
        self.isPictureCard = false
    }
    
    mutating func resetCard() {
        self.isFaceUp = false
        self.isSelected = false
        self.imageName = ""
        self.cardColor = Color.ui.scallopSeashellLight
        self.isPictureCard = false
    }
}

final class MemoryGameModel: ObservableObject {
    
    @Published var cards = [Card]()
    var cardButtons: [UIButton] = []
    let id: UUID
    var roundNumber: Int
    var numOfCardsFaceUp: Int
    var difficulty: Int
    var numCardsWithPictures: Int
    var imageName: String
    var numOfBricksOnPane: Int
    var numOfColumnsOnGrid: Int
    var gameTimer: Timer?
    @Published var gamePhase: Int
    var countTime: Int
    var pictureColor = Color.ui.scallopSeashellLight
    var noPictureColor = Color.ui.gray
    var countTimePhaseTwo = 30
    var countTimePhaseFirst = 5
    @Published var currentRound = 1
    @Published var isGameFinished = false
    var isLastRound = false
    init(id: UUID = UUID(), roundNumber: Int, difficulty: Int) {
        self.id = id
        self.roundNumber = roundNumber == -1 ? 1 : roundNumber
        self.numOfCardsFaceUp = 0
        self.numCardsWithPictures = 3
        self.difficulty = difficulty == 0 ? 1 : difficulty
        self.imageName = ""
        self.numOfBricksOnPane = 9
        self.gamePhase = 1
        self.countTime = 5
        self.numOfColumnsOnGrid = 3
    }
    
    func assignPictureCards() {
        
        let pictureCardCount = self.numCardsWithPictures
        var pictureCardIndices: [Int] = []
        
        while pictureCardIndices.count < pictureCardCount {
            let randomIndex = Int.random(in: 0..<self.cards.count)
            if !pictureCardIndices.contains(randomIndex) {
                pictureCardIndices.append(randomIndex)
            }
        }
        
        for index in pictureCardIndices {
            self.cards[index].imageName = "donut_pusheen"
            self.cards[index].isPictureCard = true
            self.cards[index].cardColor = self.pictureColor
        }
        
        for index in self.cards.indices {
            if self.cards[index].imageName == "" {
                self.cards[index].cardColor = self.noPictureColor
            }
        }
    }
    
    func setupGame() {
        let totalCards = numberOfBricksOnPane(difficulty: difficulty)
        
        for _ in 0..<totalCards {
            let card = Card(id: UUID(), isSelected: false)
            cards.append(card)
        }
        
        self.numCardsWithPictures = numberOfBricksWithPictures(difficulty: self.difficulty)
        self.gamePhase = 1
        self.numOfColumnsOnGrid = numberOfGridColumns(difficulty: self.difficulty)
        if self.roundNumber == 1{
            self.isLastRound = true
        }
    }
    
    
    
    func resetGame() {
        for index in self.cards.indices {
            self.cards[index].resetCard()
        }
        
        assignPictureCards()
        self.numOfCardsFaceUp = 0
        self.gamePhase = 1
    }
    
    func startGame() {
        
        setupGame()
        assignPictureCards()
    }
    
    func finishGame() {
        
        self.gamePhase = 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isGameFinished = true
        
        }
        
    }
    func selectCard(at index: Int) {
        if !cards[index].isSelected {
            cards[index].isSelected = true
            
            if cards[index].isPictureCard {
                self.numOfCardsFaceUp += 1
                cards[index].isFaceUp = true
            } else {
                resetGame()
            }
            
            if self.numOfCardsFaceUp == self.numCardsWithPictures {
                
                if self.currentRound == self.roundNumber && isLastRound{
                    
                    
                    finishGame()
                } else  {
                    self.currentRound = self.currentRound + 1
                    delayGame(by: 3) {
                        self.gamePhase = 3
                        self.resetGame()
                    }
                    
                    if self.currentRound == self.roundNumber {
                        self.isLastRound = true
                    }
                }
            }
        }
    }
    func numberOfBricksOnPane(difficulty: Int) -> Int {
        switch difficulty {
        case 1:
            return 9
        case 2:
            return 16
        case 3:
            return 25
        case 4:
            return 36
        case 5:
            return 49
        default:
            return 9
        }
    }
    
    func numberOfBricksWithPictures(difficulty: Int) -> Int {
        switch difficulty {
        case 1:
            return 3
        case 2:
            return 5
        case 3:
            return 7
        case 4:
            return 9
        case 5:
            return 11
        default:
            return 9
        }
    }
    
    func numberOfGridColumns(difficulty: Int) -> Int {
        switch difficulty {
        case 1:
            return 3
        case 2:
            return 4
        case 3:
            return 5
        case 4:
            return 5
        case 5:
            return 7
        default:
            return 3
        }
    }
    
    func checkGameState() {
        if self.numOfCardsFaceUp == self.numCardsWithPictures {
            finishGame()
        }
    }
    
    func changeGamePhaseToSecond() {
        self.gamePhase = 2
    }
    
    func getGamePhaseFirst() -> Bool {
        if gamePhase == 1 {
            return true
        } else {
            return false
        }
    }
    
    func getGamePhaseSecond() -> Bool {
        if gamePhase == 2 {
            return true
        } else {
            return false
        }
    }
    
    func getGamePhaseThird() -> Bool {
        if gamePhase == 3 {
            return true
        } else {
            return false
        }
    }
    
    func setAllCardsFaceUpToFalse() {
        for index in cards.indices {
            cards[index].isFaceUp = false
        }
        numOfCardsFaceUp = 0
    }
    
    func timerFinishedFirstPhaseToSecond() {
        self.gamePhase = 2
        self.countTime = self.countTimePhaseTwo
    }
    
    func delayGame(by seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

struct MemoryGameView: View {
    @ObservedObject var game: MemoryGameModel
    @Binding var showingMemoryGame: Bool
    @State var countTime = 5
    @Binding var isPreview : Bool
    @Binding var gameFinishedSuccesfully : Bool
    @State var gamePhase = 1
    @State var gameStage = 1
    var columns: [GridItem] {
        switch game.difficulty {
        case 1:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        case 2:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        case 3:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        case 4:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        case 5:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        default:
            return []
        }
    }
    
    
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                MemorizeView(gamePhaseText: $game.gamePhase)
                
                HStack {
                    RoundCount(currentRound: $game.currentRound, roundNumber: $game.roundNumber)
                    Spacer()
                    CountDownTimerView(game: game, counter: $countTime, gameFinishedSuccesfully: $gameFinishedSuccesfully,  closeView: $showingMemoryGame)
                }
                
                VStack {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(game.cards.indices, id: \.self) { index in
                            CardView(game: game, isFaceUp: $game.cards[index].isFaceUp, cardIndex: index)
                        }
                    }
                }
                .padding()
                .background(Color.ui.ivory)
                .cornerRadius(25)
                .padding()
                .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
                
                Spacer()
            }
            VStack {
                Spacer()
                if isPreview{
                    PreviewView(showingView: $showingMemoryGame)
                }
            }
        }
        .background(Color.ui.pewterWithOpacity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.scale)
        .onAppear {
            game.startGame()
            countTime = game.countTime
        }
        .onChange(of: game.gamePhase) { newValue in
            if game.getGamePhaseSecond() {
                countTime = game.countTimePhaseTwo
            } else if game.getGamePhaseFirst() {
                countTime = game.countTimePhaseFirst
            }
        }
        .onChange(of: game.isGameFinished) { newValue in
            if game.isGameFinished{
                showingMemoryGame = false
                gameFinishedSuccesfully = false
                gameStage = 1
            }
        }
    }
}
// Card code inspired by: https://betterprogramming.pub/card-flip-animation-in-swiftui-45d8b8210a00
struct FrontSideCard: View {
    @Binding var angle: Double
    var imageName: String
    var cardColor: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(cardColor, lineWidth: 3)
                .aspectRatio(1, contentMode: .fit)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: .gray, radius: 2, x: 1, y: 1)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor)
                .aspectRatio(1, contentMode: .fit)
                .padding(4)
            
            if imageName != "" {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.7)
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
            }
        }
        .rotation3DEffect(Angle(degrees: angle), axis: (x: 0, y: 1, z: 0))
    }
}

struct BackSideCard: View {
    @Binding var angle: Double
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.ui.scallopSeashell, lineWidth: 3)
                .aspectRatio(1, contentMode: .fit)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.ui.scallopSeashell.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: .gray, radius: 2, x: 1, y: 1)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.ui.scallopSeashell)
                .aspectRatio(1, contentMode: .fit)
                .padding(4)
        }
        .rotation3DEffect(Angle(degrees: angle), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardView: View {
    @State var backAngle = 0.01
    @State var frontAngle = -90.0
    @State var hasFlipped = false
    @State var game: MemoryGameModel
    @Binding var isFaceUp: Bool
    var cardIndex: Int
    
    let durationDelay: CGFloat = 0.3
    
    func flipTheCardWithAnimationFaceUp() {
        withAnimation(.linear(duration: durationDelay)) {
            backAngle = 90
        }
        withAnimation(.linear(duration: durationDelay).delay(durationDelay)){
            frontAngle = 0.01
        }
    }
    
    func flipTheCardWithAnimationFaceDown() {
        withAnimation(.linear(duration: durationDelay)) {
            if isFaceUp{
                frontAngle = 90
            }
            else{
                frontAngle = -90
            }
        }
        withAnimation(.linear(duration: durationDelay).delay(durationDelay)){
            backAngle = 0.05
        }
    }
    
    var body: some View {
        ZStack {
            FrontSideCard(angle: $frontAngle, imageName: game.cards[cardIndex].imageName, cardColor: game.cards[cardIndex].cardColor)
            BackSideCard(angle: $backAngle)
        }
        .padding(3)
        .frame(width: UIScreen.main.bounds.width / (CGFloat(game.numOfColumnsOnGrid) + 2), height:  UIScreen.main.bounds.width / (CGFloat(game.numOfColumnsOnGrid) + 2))
        .shadow(color: Color.ui.pewter, radius: 2, x: 0, y: 2)
        .onTapGesture {
            flipTheCardWithAnimationFaceUp()
            game.selectCard(at: cardIndex)
        }
        .onChange(of: game.gamePhase) { newValue in
            if game.getGamePhaseSecond() || game.getGamePhaseThird() {
                flipTheCardWithAnimationFaceDown()
            } else if game.getGamePhaseFirst() {
                flipTheCardWithAnimationFaceUp()
            }
        }
        .onAppear {
            if game.getGamePhaseFirst() {
                flipTheCardWithAnimationFaceUp()
            }
        }
    }
}

struct CountDownTimerView: View {
    @State var game: MemoryGameModel
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Binding var counter: Int
    @Binding var gameFinishedSuccesfully : Bool
    @Binding var closeView : Bool
    var body: some View {
        VStack {
            Text("\(counter)")
                .font(.system(size: 35, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding()
                .onReceive(timer) { _ in
                    if self.counter > 0 {
                        self.counter -= 1
                        if self.counter == 1{
                            if game.getGamePhaseSecond(){
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    gameFinishedSuccesfully = true
                                    closeView = false
                                }
                            }
                        }
                    } else {
                        if game.getGamePhaseFirst() {
                            game.timerFinishedFirstPhaseToSecond()
                        }
                        
                    }
                }
        }
        .padding()
        .frame(minWidth: 0,
               maxWidth: .infinity
        )
        .background(Color.ui.deepRed)
        .cornerRadius(15)
        .padding()
        .shadow(color: .gray, radius: 7, x: 0, y: 0)
    }
}

struct RoundCount: View {
    @Binding var currentRound : Int
    @Binding var roundNumber : Int
    var body: some View {
        VStack {
            Text("\(currentRound)/\(roundNumber)")
                .font(.system(size: 35, weight: .bold, design: .monospaced))
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

struct MemorizeView: View {
    @Binding var gamePhaseText: Int
    @State var frontAngle = 0.0
    
    var body: some View {
        HStack {
            if gamePhaseText == 1 {
                Text("Memorize!")
                    .font(.custom("Poppins-Bold", size: 20))
            } else if gamePhaseText == 2 {
                Text("Find!")
                    .font(.custom("Poppins-Bold", size: 20))
                VStack {
                    FrontSideCard(angle: $frontAngle, imageName: "donut_pusheen", cardColor: Color.ui.scallopSeashellLight)
                        .padding()
                }
            }
            else if gamePhaseText == 3{
                Text("Success!")
                    .font(.custom("Poppins-Bold", size: 20))
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height:  UIScreen.main.bounds.height * 0.10)
        .background(gamePhaseText == 3 ? Color.ui.lightGreen  : Color.ui.ivory )
        .cornerRadius(15)
        .padding()
        .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
    }
}

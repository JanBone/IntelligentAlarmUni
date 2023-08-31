
import Foundation
import UIKit
import SwiftUI
import Combine


struct MissionSubView: View {
    @Binding var showingMissionView: Bool
    @Binding var selectedMission : Int
    var body: some View {
        ButtonSubViewForActions(title: "Mission", subtitle: selectMissionName(missionName: selectedMission)) {
            showingMissionView.toggle()
        }
    }
    private func selectMissionName(missionName: Int) -> String {
        switch missionName {
        case -1:
            return "Off"
        case 1:
            return "Memory"
        case 2:
            return "Steps"
        case 3:
            return "Math"
        case 4:
            return "Shake"
        case 5:
            return "Typing"
        default:
            return "Off"
        }
    }
}


struct MissionIcon: View {
    var imageName: String
    var cardColor: Color
    var missionName: String
    @Binding var missionIsPresented: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                missionIsPresented = true
            }
        }) {
            VStack(spacing: 0) {
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
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(0.7)
                }
                .padding(2)
                .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
                
                Text(missionName)
                    .font(Font.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(Color.ui.darkGray)
                    .lineLimit(2)
            }
            .frame(width: UIScreen.main.bounds.width / 3.5, height: UIScreen.main.bounds.height / 6)
            .padding(2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CloseButton: View {
    @Binding var isPresented: Bool
    var body: some View {
        Button(action: {
            withAnimation {
                isPresented = false
            }
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 25))
                .foregroundColor(.white)
                .padding()
                .background(Color.ui.deepRed)
                .clipShape(Circle())
        }
        .shadow(color: Color.ui.darkGray, radius: 7, x: 0, y: 2)
    }
}


struct MissionView: View {
    let rows = [
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
    ]
    
    @Binding var isMissionViewPresented: Bool
    @State var memoryGameSettingsIsPresented: Bool = false
    @State var countingStepsSettingsIsPresented: Bool = false
    @State var shakesSettingsIsPresented: Bool = false
    @State var mathGameSettingsIsPresented: Bool = false
    @State var noMissionPresented : Bool = false
    
    @Binding var difficulty : Int
    @Binding var numberOfProblems : Int
    @Binding var missionName : Int
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    CloseButton(isPresented: $isMissionViewPresented)
                }
                .padding()
                
                Spacer()
                
                Text("Pick a mission")
                    .font(Font.custom("Poppins-Bold", size: 30))
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .foregroundColor(Color.ui.darkGray)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.ui.oliveLight2.opacity(0.9))
                            .shadow(color: Color.ui.pewter, radius: 7, x: 0, y: 2)
                    )
                    .padding()
                
                LazyHGrid(rows: rows) {
                    MissionIcon(imageName: "memory_game_icon", cardColor: Color.ui.scallopSeashellLight, missionName: "Memory", missionIsPresented: $memoryGameSettingsIsPresented)
                    MissionIcon(imageName: "shake_phone", cardColor: Color.ui.scallopSeashellLight, missionName: "Shake", missionIsPresented: $shakesSettingsIsPresented)
                    MissionIcon(imageName: "step3", cardColor: Color.ui.scallopSeashellLight, missionName: "Step", missionIsPresented: $countingStepsSettingsIsPresented)
                    MissionIcon(imageName: "circle_slash", cardColor: Color.ui.scallopSeashellLight, missionName: "No mission", missionIsPresented: $noMissionPresented)
                    MissionIcon(imageName: "math", cardColor: Color.ui.scallopSeashellLight, missionName: "Math", missionIsPresented: $mathGameSettingsIsPresented)
                }
                .frame(maxHeight: UIScreen.main.bounds.height / 2.5)
                .padding()
                
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .background(Color.ui.pewterWithOpacity)
            
            Group {
                
                if memoryGameSettingsIsPresented {
                    MemoryGameSettingsView(selectedRoundNumber: $numberOfProblems, selectedDifficulty: $difficulty, showingMemoryGameSettingsView: $memoryGameSettingsIsPresented, missionName : $missionName)
                    
                } else if countingStepsSettingsIsPresented {
                    CountingStepsSettingsView(showingCountingStepsSettingsView: $countingStepsSettingsIsPresented, numberOfSteps: $numberOfProblems, missionName : $missionName)
                }
                else if shakesSettingsIsPresented {
                    
                    ShakeSettingsMissionView(showingShakeSettingsView: $shakesSettingsIsPresented, shakeTotalCount: $numberOfProblems, ShakeIntensity: $difficulty, missionName : $missionName)
                }
                
                else{
                    if mathGameSettingsIsPresented{
                        MathGameSettingsMissionView(showingMathSettingsView: $mathGameSettingsIsPresented, mathGameNumberOfProblems: $numberOfProblems, mathGameDifficulty: $difficulty, missionName : $missionName)
                    }
                }
            }
        }.onChange(of:  noMissionPresented) { newValue in
            if newValue {
                missionName = -1
            }
        }
    }
    func closeMissionView() {
        withAnimation {
            isMissionViewPresented = false
        }
    }
    
}

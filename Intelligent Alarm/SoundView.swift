//
//  SoundView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 08/06/2023.
//

import Foundation
import SwiftUI

struct SoundSubView: View {
    @Binding var selectedSound : Int
    @Binding var showingSoundView: Bool
    
    var body: some View {
        ButtonSubViewForActions(title: "Sound", subtitle: selectSoundName(missionName: selectedSound)) {
            self.showingSoundView.toggle()
        }
    }
    private func selectSoundName(missionName: Int) -> String {
        switch missionName {
        case 1:
            return "Sunrise"
        case 2:
            return "Serenity"
        case 3:
            return "Alert"
        default:
            return "Off"
        }
    }
    
    
}

struct SoundView: View {
    @Binding var showingSoundView: Bool
    @Binding var soundManager: SoundManager
    @Binding var selectedSound : Int
    var body: some View {
        VStack {
            
            AlarmSoundList(soundManager: soundManager, selectedSound: $selectedSound)
                .font(Font.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(Color.ui.darkGray)
            HStack {
                Spacer()
                NavigationButton(buttonText: "Cancel", action: close)
                NavigationButton(buttonText: "Done", action: close)
            }.padding()
            
        }.border(Color.ui.pewter)
            .background(Color.ui.ivory)
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .background(Rectangle().fill(Color(UIColor.systemBackground)))
            .cornerRadius(20)
            .padding()
        
    }
    
    private func close() {
        showingSoundView.toggle()
    }
}

struct SoundRowView: View {
    @Binding var item: ItemSound
    
    var body: some View {
        HStack {
            Text(item.itemText)
            Image(systemName: "music.note")
            Spacer()
            CheckBoxView(isChecked: item.selected, checkMarkShape: "circle")
        }
        
        .contentShape(Rectangle())
    }
}

struct AlarmSoundList: View {
    @ObservedObject var soundManager: SoundManager
    @Binding var selectedSound : Int
    let elementsCount = 4
    let listRowHeight = 35
    
    var body: some View {
        List {
            ForEach($soundManager.sounds) { $sound_ in
                SoundRowView(item: $sound_)
                    .onTapGesture {
                        soundManager.selectItem(sound_)
                        selectedSound = sound_.interValue
                    }
                
            }.listRowBackground(Color.ui.ivory)
        }
        .listStyle(PlainListStyle())
        .frame(height: CGFloat(elementsCount) * CGFloat(listRowHeight))
        .padding()
        
    }
}


class SoundManager: ObservableObject {
    @Published var sounds = [
        ItemSound(selected: true, itemText: "Sunrise", interValue: 1),
        ItemSound(selected: false, itemText: "Serenity", interValue: 2),
        ItemSound(selected: false, itemText: "Alert", interValue: 3),
    ]
    func selectItem(_ item: ItemSound) {
        for index in 0..<sounds.count {
            if sounds[index].id == item.id {
                
                sounds[index].selected = true
            } else {
                sounds[index].selected = false
            }
        }
    }
}

struct ItemSound: Identifiable, Hashable, Codable {
    var id = UUID()
    var selected = false
    var itemText: String
    var interValue: Int
}

//
//  AlarmListView.swift
//  Intelligent Alarm
//
//  Created by Katia on 02/05/2022.
//

import Foundation
import SwiftUI


struct AlarmListView: View {
    @EnvironmentObject var alarmData: AlarmData
    @State var memoryGameSettingsIsPresented = false
    @Binding var isAlarmEdited : Bool
    @Binding var alarmId : String
    @Binding var isAlarmOptionsShowing : Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                ForEach(alarmData.alarmsList.filter { !$0.isSnoozer }, id: \.self) { alarmObject in
                    AlarmBlockView(alarmObject: $alarmData.alarmsList[alarmData.alarmsList.firstIndex(where: { $0.id == alarmObject.id })!])
                        .swipeActions(allowsFullSwipe: true) {
                            deleteButton(for: alarmObject).tint(Color.ui.gray)
                        } .listRowBackground(Color.ui.pewter.opacity(0.2))
                        .onTapGesture {
                            showEditView(id: alarmObject.id.uuidString)
                        }
                }
            }.listStyle(PlainListStyle())
                .listRowSeparator(.hidden)
        }
        .background(Color.ui.pewter.opacity(0.3))
        
    }
    private func showEditView(id: String) {
        alarmId = id
        isAlarmEdited = true
        isAlarmOptionsShowing = true
    }
    
    private func deleteButton(for alarmObject: AlarmObject) -> some View {
        Button() {
            withAnimation {
                alarmData.remove(alarmObject: alarmObject)
            }
        }label: {
            Label("", systemImage: "trash.fill")
            
        }
    }
    
    
}




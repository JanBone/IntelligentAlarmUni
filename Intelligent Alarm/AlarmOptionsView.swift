//
//  AlarmOptionsView.swift
//  Intelligent Alarm
//
//  Created by Katia on 02/05/2022.
//

import Foundation
import SwiftUI


struct PickerView: View {
    @Binding var selection: Int
    var values: [Int]
    var currentValue: Binding<Int>
    
    var body: some View {
        Picker(selection: self.$selection, label: Text("")) {
            ForEach(0..<self.values.count) { index in
                Text("\(String(format: "%02d", self.values[index]))")
                    .tag(index)
                    .font(Font.custom("Poppins-Bold", size: 25))
                    .foregroundColor(Color.ui.darkGray)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: UIScreen.main.bounds.width * 1 / 3)
        .clipped()
        .onChange(of: selection) { newValue in
            currentValue.wrappedValue = values[newValue]
        }
    }
}

struct AlarmPickerWheels: View {
    @State var selectedHours = 0
    @State var selectedMinutes = 0
    @Binding var currentHours: Int
    @Binding var currentMinutes: Int
    @Binding var dayNumberFirst: Int
    @Binding var itemsManagerDays : DaysOfTheWeekManager
    var hours = [Int](0..<24)
    var minutes = [Int](0..<60)
    @State var timeTillAlarm = "Alarm will ring in 1 minute"
    var body: some View {
        
        VStack() {
            Text(calculateTimeUntilNextAlarm(selectedHours:selectedHours , selectedMinutes: selectedMinutes, repeatDays: itemsManagerDays.days)).padding().font(Font.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(Color.ui.darkGray)
            HStack(spacing: 0) {
                PickerView(selection: $selectedHours, values: hours, currentValue: $currentHours)
                PickerView(selection: $selectedMinutes, values: minutes, currentValue: $currentMinutes)
            }.padding()
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .contentShape(Rectangle())
                .onAppear(perform: setCurrentHourAndMinute)
        }
        .background(Color.ui.oliveLight2)
        .cornerRadius(20)
        .padding()
        .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
        
    }
    
    private func setCurrentHourAndMinute() {
        let date = Date()
        let calendar = Calendar.current
        selectedHours = calendar.component(.hour, from: date)
        selectedMinutes = calendar.component(.minute, from: date)
    }
}




struct AlarmOptions: View {
    @State var showingRepeatView = false
    @State var showingSnoozeView = false
    @State var showingSoundView = false
    @State var showingMissionView = false
    
    @State var hourSelected = 24
    @State var minuteSelected = 24
    
    @State var repeatDaysState = DaysOfTheWeekManager()
    @State var soundState = SoundManager()
    @State var snoozeTime = -1
    @State var firstDay = 1
    @State var repeatAlarm = false
    @State var alarmSoundSelected = 1
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var alarmData: AlarmData
    
    @State var difficulty = -1
    @State var numberOfProblems = -1
    @State var missionName = -1
    @Binding var showingAlarmOptionsView : Bool
    @Binding var isEdit : Bool
    @Binding var alarmEditedId : String
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    contentStack
                    Spacer()
                    buttonStack
                    Spacer()
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                .blur(radius: (self.showingRepeatView || self.showingSnoozeView || self.showingSoundView) ? 5 : 0)
                
                if showingRepeatView {
                    RepeatDaysView(showingRepeatView: $showingRepeatView, itemsState: $repeatDaysState)
                } else if showingSnoozeView {
                    SnoozeView(showingSnoozeView: $showingSnoozeView, snoozeTime: $snoozeTime)
                } else if showingSoundView {
                    SoundView(showingSoundView: $showingSoundView, soundManager: $soundState, selectedSound: $alarmSoundSelected)
                }
                else if showingMissionView{
                    MissionView(isMissionViewPresented: $showingMissionView, difficulty: $difficulty, numberOfProblems: $numberOfProblems, missionName: $missionName)
                    
                }
                
            }
        }.background(Color.ui.pewter.opacity(0.2))
            .frame(maxWidth: .infinity)
            .onAppear(perform: {
                editAlarm(alarmID: alarmEditedId)
            })
    }
    
    private var contentStack: some View {
        VStack {
            AlarmPickerWheels(currentHours: $hourSelected, currentMinutes: $minuteSelected, dayNumberFirst: $firstDay, itemsManagerDays: $repeatDaysState)
            Spacer()
            
            MissionSubView(showingMissionView: $showingMissionView, selectedMission: $missionName)
            Spacer()
            RepeatSubView(showingRepeatView: $showingRepeatView, selectedDays: $repeatDaysState)
            Spacer()
            SoundSubView(selectedSound: $alarmSoundSelected, showingSoundView: $showingSoundView)
            Spacer()
            SnoozeSubView(showingSnoozeView: $showingSnoozeView, snoozeMinutesSelected: $snoozeTime)
            Spacer()
        }
    }
    
    private var buttonStack: some View {
        HStack {
            if isEdit{
                NavigationButtonVeiw(buttonText: "Done", function: updateAlarm)
            }
            else{
                NavigationButtonVeiw(buttonText: "Done", function: createNewAlarm)
            }
            Spacer()
            NavigationButtonVeiw(buttonText: "Cancel", function: closeView)
        }
    }
    
    private func createNewAlarm() {
        var is_repeated = IsRepeat(daysList: repeatDaysState)
        if hourSelected == 24{
            hourSelected = 00
        }
        var notifications = setAlarm(repeat_alarm: is_repeated, repeatList: repeatDaysState.days, hour: hourSelected, minute:  minuteSelected)
        let newAlarm = AlarmObject(
            isActive: true,
            hour: hourSelected,
            minute: minuteSelected,
            repeatList: repeatDaysState.days,
            snooze: snoozeTime,
            repeat_alarm: is_repeated,
            difficulty: difficulty,
            missionName: missionName != -1 ? missionName : 5,
            numberOfProblems : numberOfProblems != -1 ? numberOfProblems : 1,
            alarmSound: alarmSoundSelected,
            notifications: notifications,
            firstAlarmWeekDay: setFirstAlarmDay(hour: hourSelected, minute: minuteSelected),
            isSnoozer: false,
            originalAlarmId: nil
            
        )
        self.alarmData.addAlarm(alarmObject: newAlarm)
        closeView()
    }
    private func editAlarm(alarmID : String) {
        var alarm = self.alarmData.findAlarmByID(idToFind: alarmID)
        
        if alarm != nil {
            hourSelected = alarm?.hour ?? hourSelected
            minuteSelected = alarm?.minute ?? minuteSelected
            repeatDaysState.days = alarm?.repeatList ?? repeatDaysState.days
            snoozeTime = alarm?.snooze ?? snoozeTime
            difficulty = alarm?.difficulty ?? difficulty
            missionName = alarm?.missionName ?? missionName
            alarmSoundSelected = alarm?.alarmSound ?? alarmSoundSelected
            
        }
        
    }
    private func updateAlarm() {
        var isRepeat = IsRepeat(daysList: repeatDaysState)
        let alarm = self.alarmData.findAlarmByID(idToFind: alarmEditedId)
        let notifications = setAlarm(repeat_alarm: isRepeat, repeatList: repeatDaysState.days, hour: hourSelected, minute:  minuteSelected)
        alarm?.removeAllNotifications()
        if alarm != nil {
            alarm?.isActive = true
            alarm?.hour = hourSelected
            alarm?.minute =  minuteSelected
            alarm?.repeatList = repeatDaysState.days
            alarm?.snooze = snoozeTime
            alarm?.repeat_alarm = isRepeat
            alarm?.difficulty = difficulty
            alarm?.missionName = missionName != -1 ? missionName : 5
            alarm?.numberOfProblems =  numberOfProblems != -1 ? numberOfProblems : 1
            alarm?.alarmSound = alarmSoundSelected
            alarm?.notificationObjects = notifications
        }
        closeView()
    }
    
    private func closeView() {
        withAnimation {
            showingAlarmOptionsView = false
        }
    }
}


struct NavigationButtonVeiw: View {
    let buttonText: String
    var function: () -> Void
    var body: some View {
        Button(
            action: {
                function()
            },
            label: {
                Text(buttonText)
                    .padding()
                    .font(Font.custom("Poppins-Bold", size: 20))
                    .foregroundColor(Color.white)
                    .frame(width:  UIScreen.main.bounds.width / 2.3 )
                    .background(Color.ui.pewter)
                    .clipShape(RoundedRectangle(cornerRadius: 15.0, style: .continuous))
                    .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
            }).padding(.horizontal)
    }
}


struct ButtonSubViewForActions: View {
    var title: String
    var subtitle: String
    var action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: action) {
                HStack(spacing: 0) {
                    Text(title).font(Font.custom("Poppins-SemiBold", size: 20))
                    Spacer()
                    Text(subtitle + "  ").font(Font.custom("Poppins-SemiBold", size: 20))
                    Image(systemName: "chevron.forward").font(Font.custom("Poppins-Bold", size: 20))
                }
                .foregroundColor(Color.ui.darkGray)
                .padding()
            }
            .accentColor(.white)
            
        }
        .frame(height:  UIScreen.main.bounds.height / 12 )
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(Color.ui.scallopSeashell)
                .shadow(color: Color.ui.pewter, radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

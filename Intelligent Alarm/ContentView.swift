

import SwiftUI
import SwiftUI
import CoreMotion




struct ContentView: View {
    @EnvironmentObject var alarmData : AlarmData
    @State var showAlarmOptions = false
    @EnvironmentObject var alarmPlayer : AlarmPlayer
    @State var isEdit = false
    @State var alarmIdToShow = "alarm_id"
    
    var body: some View {
        ZStack {
            if !showAlarmOptions {
                AlarmListView(isAlarmEdited: $isEdit, alarmId: $alarmIdToShow, isAlarmOptionsShowing: $showAlarmOptions).environmentObject(alarmData)
                StartPageView(showAlarmOptions: $showAlarmOptions).environmentObject(alarmData)
            }
            if showAlarmOptions {
                AlarmOptions(showingAlarmOptionsView: $showAlarmOptions, isEdit: $isEdit, alarmEditedId: $alarmIdToShow)
                    .transition(.scale)
            }
            
        }.overlay(alarmData.showWindow ? ActiveAlarmView().environmentObject(alarmData).environmentObject(alarmPlayer) :  nil)
        
    }
}


struct StartPageView: View {
    @Binding var showAlarmOptions : Bool
    @State private var checked = true
    var body: some View {
        VStack {
            Group{
                Button(action: {
                    withAnimation{
                        showAlarmOptions = true
                    }
                    
                },  label: {
                    Text("+")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.ui.pewter)
                        .cornerRadius(20).clipShape(Circle())
                })
                
            }.frame(minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity, alignment: .bottom)
            .shadow(color: Color.ui.darkGray, radius: 15, x: 0, y: 2)
        }
        
    }
}











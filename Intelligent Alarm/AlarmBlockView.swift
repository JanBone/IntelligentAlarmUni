//
//  AlarmBlockView.swift
//  Intelligent Alarm
//
//  Created by Katia on 02/05/2022.
//

import SwiftUI


struct CustomToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(isOn ? Color.ui.deepRed : Color.ui.gray)
                .frame(width: 60, height: 30)
                .shadow(color: isOn ? Color.ui.deepRed.opacity(3) : Color.clear, radius: 15)
            
            Circle()
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .offset(x: isOn ? 15 : -15, y: 0)
                .animation(.spring())
        }
        .onTapGesture {
            
            isOn.toggle()
        }
    }
}

struct RepeatDaysListView: View {
    @Binding var alarmObject: AlarmObject
    
    var body: some View {
        Group {
            ForEach($alarmObject.repeatList) { $item in
                DayOfWeekLetter(itemDay: $item)
                    .font(Font.custom("Poppins-SemiBold", size: 18))
                    .padding(.trailing, -4)
            }
        }
    }
}

struct TimeAndToggleView: View {
    @Binding var alarmObject: AlarmObject
    
    var body: some View {
        HStack {
            Text("\(String(format: "%02d", alarmObject.hour)):\(String(format: "%02d", alarmObject.minute))").font(Font.custom("Poppins-SemiBold", size: 37))
                .foregroundColor(Color.ui.darkGray)
            Spacer()
            
            CustomToggle(isOn: $alarmObject.isActive)
        }
    }
}

struct AlarmBlockView: View {
    @Binding var alarmObject: AlarmObject
    @State private var isSliding = false
    @State private var isTrashBinMoving = false
    
    var body: some View {
        ZStack {
            TrashBin()
            alarmBlockContent
                .offset(x: isSliding ? -300 : 0)
        }
    }
    
    var alarmBlockContent: some View {
        VStack(spacing: 0) {
            HStack {
                RepeatDaysListView(alarmObject: $alarmObject)
                Spacer()
            }
            .padding(EdgeInsets(top: 3, leading: 15, bottom: 0, trailing: 15))
            
            HStack {
                Spacer().frame(width: UIScreen.main.bounds.width / 14)
                TimeAndToggleView(alarmObject: $alarmObject)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                    .frame(height: UIScreen.main.bounds.height * 1 / 9)
            }
        }
        .frame(height: UIScreen.main.bounds.height * 1 / 6)
        .background(Color.ui.scallopSeashell)
        .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .shadow(color: Color.ui.pewter, radius: 3, x: 0, y: 0)
    }
}

struct TrashBin: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("trash bin")
            }
            Spacer()
        }
    }
}

struct DayOfWeekLetter: View {
    @Binding var itemDay: ItemDay
    
    var body: some View {
        Text(itemDay.itemLetter)
            .foregroundColor(itemDay.selected ? Color.ui.black :  Color.ui.white)
    }
}

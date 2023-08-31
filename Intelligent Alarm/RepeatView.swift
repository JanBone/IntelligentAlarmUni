//
//  RepeatView.swift
//  Intelligent Alarm
//
//  Created by Katia on 18/04/2022.
//

import Foundation
import SwiftUI

struct RepeatSubView: View {
    @Binding var showingRepeatView: Bool
    @Binding var selectedDays : DaysOfTheWeekManager
    var body: some View {
        ButtonSubViewForActions(title: "Repeat", subtitle: selectRepeatTitle(daysState: selectedDays)) {
            self.showingRepeatView.toggle()
        }
    }
    
    private func selectRepeatTitle(daysState : DaysOfTheWeekManager) -> String{
        var repeatDaysStringList = ""
        if daysState.days[5].selected && daysState.days[6].selected && !(daysState.days[0].selected || daysState.days[1].selected || daysState.days[2].selected || daysState.days[3].selected || daysState.days[4].selected){
            repeatDaysStringList = "Weekends"
        }
        else if daysState.days[0].selected && daysState.days[1].selected && daysState.days[2].selected && daysState.days[3].selected && daysState.days[4].selected && !(daysState.days[5].selected || daysState.days[6].selected){
            repeatDaysStringList = "Weekdays"
        }
        else{
            var numberOfDaysSelected = 0
            for days in daysState.days{
                if days.selected{
                    numberOfDaysSelected += 1
                    repeatDaysStringList = repeatDaysStringList + days.itemLetter + ", "
                }
            }
            
            if numberOfDaysSelected == 0{
                repeatDaysStringList = "Never"
            }
            else if numberOfDaysSelected == 7{
                repeatDaysStringList = "Everyday"
            }
            else if numberOfDaysSelected != 0{
                repeatDaysStringList.removeLast(2)
            }
            else{
                repeatDaysStringList = "Never"
            }
        }
        return repeatDaysStringList
    }
    
}

struct RepeatDaysView: View {
    @Binding var showingRepeatView: Bool
    @Binding var itemsState: DaysOfTheWeekManager
    @State private var weekdaysPressed = false
    @State private var weekendsPressed = false
    var body: some View {
        VStack {
            HStack {
                SelectDaysButton(buttonText: "Weekends", isSelected: weekendsPressed, action: selectWeekendDays)
                SelectDaysButton(buttonText: "Weekdays", isSelected: weekdaysPressed, action: selectWeekdays)
            }.padding()
            DaysList(itemsState: itemsState)
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
    
    private func selectWeekendDays() {
        let setValue = !weekendsPressed
        for (index, item) in itemsState.days.enumerated() where item.isWeekend {
            itemsState.days[index].selected = setValue
        }
        weekendsPressed.toggle()
    }
    
    private func selectWeekdays() {
        let setValue = !weekdaysPressed
        
        for (index, item) in itemsState.days.enumerated() where !item.isWeekend {
            itemsState.days[index].selected = setValue
        }
        weekdaysPressed.toggle()
    }
    
    private func close() {
        showingRepeatView.toggle()
    }
}

struct CheckBoxView: View {
    var isChecked: Bool
    var checkMarkShape : String
    var body: some View {
        Image(systemName: isChecked ? "checkmark.\(checkMarkShape).fill" : checkMarkShape)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundColor(isChecked ? Color.ui.deepRed : Color.ui.darkGray)
    }
}

struct SelectDaysButton: View {
    let buttonText: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.ui.pewter : Color.ui.gray)
                .cornerRadius(10)
        }.font(Font.custom("Poppins-SemiBold", size: 18))
            .foregroundColor(.white)
            .padding(5)
            .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
    }
}

struct DaysList: View {
    @ObservedObject var itemsState: DaysOfTheWeekManager
    let elementsCount = 8
    let listRowHeight = 38
    
    var body: some View {
        List {
            ForEach($itemsState.days) { $day_ in
                RepeatDay(item: $day_)
                    .onTapGesture {
                        day_.selected.toggle()
                    }
                
            }.listRowBackground(Color.ui.ivory)
        }
        .listStyle(PlainListStyle())
        .frame(height: CGFloat(elementsCount) * CGFloat(listRowHeight))
        
    }
}

struct NavigationButton: View {
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.ui.scallopSeashell)
                .cornerRadius(10)
                .font(Font.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(.white)
            
            
        }.shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
    }
}



struct RepeatDay: View {
    @Binding var item: ItemDay
    
    var body: some View {
        HStack {
            Text(item.itemText)
            Spacer()
            CheckBoxView(isChecked: item.selected, checkMarkShape: "square")
        }
        .contentShape(Rectangle())
    }
}

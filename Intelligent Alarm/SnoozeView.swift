//
//  SnoozeView.swift
//  Intelligent Alarm
//
//  Created by Kate on 22/05/2022.
//

import Foundation
import SwiftUI

struct SnoozeSubView: View {
    @Binding var showingSnoozeView: Bool
    @Binding var snoozeMinutesSelected : Int
    var body: some View {
        ButtonSubViewForActions(title: "Snooze", subtitle: selectSnoozeTitle(snoozeMinutesNumber: snoozeMinutesSelected))
        {
            withAnimation{
                self.showingSnoozeView.toggle()
            }
            
        }
    }
    private func selectSnoozeTitle(snoozeMinutesNumber: Int) -> String {
        if snoozeMinutesNumber == 0 || snoozeMinutesNumber == -1{
            return "Off"
        }
        else{
            if snoozeMinutesNumber == 1{
                return String(snoozeMinutesNumber) + " min"
            }
            else{
                return String(snoozeMinutesNumber) + " min"
            }
        }
    }
    
}

struct Checkmark: Identifiable, Hashable {
    var id = UUID()
    var state = false
    var text : String
}

struct SnoozeView: View {
    @Binding var showingSnoozeView: Bool
    @Binding var snoozeTime : Int
    var body: some View {
        VStack(spacing : 0) {
            MinutesList(snoozeTime: $snoozeTime).font(Font.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(Color.ui.darkGray)
            HStack {
                NavigationButton(buttonText: "Done", action: close)
                NavigationButton(buttonText: "Cancel", action: close)
            }.padding()
            
            
        }.border(Color.ui.pewter)
            .background(Color.ui.ivory)
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .background(Rectangle().fill(Color(UIColor.systemBackground)))
            .cornerRadius(20)
            .padding()
    }
    private func close(){
        withAnimation{
            showingSnoozeView.toggle()
        }
        
    }
    
}
struct MarkedItemMinutes: Identifiable, Hashable {
    var id = UUID()
    var selected = false
    var itemText : String
    var interValue : Int
}

class ItemsManagerMinutes : ObservableObject {
    @Published var items = [MarkedItemMinutes(itemText: "Off", interValue: -1), MarkedItemMinutes(itemText: "1 minute", interValue: 1), MarkedItemMinutes(itemText: "5 minutes", interValue: 5), MarkedItemMinutes(itemText: "10 minutes", interValue: 10), MarkedItemMinutes(itemText: "15 minutes", interValue: 15), MarkedItemMinutes(itemText: "20 minutes", interValue: 20), MarkedItemMinutes(itemText: "25 minutes", interValue: 25), MarkedItemMinutes(itemText: "30 minutes", interValue: 30), MarkedItemMinutes(itemText: "45 minutes", interValue: 45), MarkedItemMinutes(itemText: "1 hour", interValue: 60)]
}


struct MinutesList: View {
    @ObservedObject var itemsState = ItemsManagerMinutes()
    @State private var selectedItem: MarkedItemMinutes.ID?
    @Binding var snoozeTime : Int
    var elementsCount = 10
    var listRowHeight = 35
    
    var body: some View {
        List {
            ForEach($itemsState.items) { $item in
                SelectedSnoozeMinutes(selectedItem: $selectedItem, item: $item)
                    .onTapGesture {
                        if let index = itemsState.items.firstIndex(where: { $0.id == selectedItem}) {
                            itemsState.items[index].selected = false
                        }
                        item.selected = true
                        selectedItem = item.id
                        snoozeTime = item.interValue
                        
                    }
            }.listRowBackground(Color.ui.ivory)
        }
        .listStyle(PlainListStyle())
        .frame(height: CGFloat(elementsCount) * CGFloat(listRowHeight))
        
    }
}

struct SelectedSnoozeMinutes: View {
    @Binding var selectedItem: MarkedItemMinutes.ID?
    @Binding var item: MarkedItemMinutes
    
    var body: some View {
        HStack {
            Text(item.itemText)
            Spacer()
            if item.id == selectedItem {
                Image(systemName: "checkmark")
                
            }
        }.contentShape(Rectangle())
    }
}




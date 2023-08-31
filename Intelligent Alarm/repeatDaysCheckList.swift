//
//  repeatDaysCheckList.swift
//  Intelligent Alarm
//
//  Created by Katia on 17/04/2022.
//

import Foundation


struct CheckBoxView: View {
    @Binding var checked: Bool

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
            .onTapGesture {
                self.checked.toggle()
            }
    }
}


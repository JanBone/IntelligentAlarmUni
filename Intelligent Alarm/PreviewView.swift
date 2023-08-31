//
//  PreviewView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 28/06/2023.
//

import Foundation
import UIKit
import SwiftUI
import Combine


struct PreviewView: View {
    @Binding var showingView: Bool
    var body: some View {
        VStack{
            HStack {
                Spacer()
                Button(action: {
                    showingView = false
                }) {
                    Text("Exit preview")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.ui.gray)
                        .cornerRadius(10)
                }
                .padding()
                Spacer()
            }
        }
        .background(Color.ui.SunflowerYellow .opacity(0.3))
        
    }
}


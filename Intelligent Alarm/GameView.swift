//
//  GameView.swift
//  Intelligent Alarm
//
//  Created by Katsiaryna Yalovik on 09/06/2023.
//

import Foundation
import SwiftUI

struct GameButtonsView: View {
    let buttonText: String
    var function: () -> Void
    var body: some View {
        Button(
            action: {
                withAnimation{
                    function()
                }
                
            },
            label: {
                Text(buttonText)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 60)
                    .background(Color.ui.pewter)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                    .font(.custom("Poppins-SemiBold", size: 17))
                    .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
            })
    }
}

struct PreviewButtonView: View {
    let buttonText: String
    var function: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                function()
            }, label: {
                Text(buttonText)
                    .padding()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.ui.white)
                    .background(Color.ui.SunflowerYellow)
                    .clipShape(Circle())
                    .font(.custom("Poppins-SemiBold", size: 17))
                    .shadow(color: Color.ui.pewter, radius: 5, x: 0, y: 2)
            })
            
        }
        
    }
}

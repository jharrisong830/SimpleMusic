//
//  ProminentButtonStyle.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import SwiftUI

struct ProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .padding(.horizontal, 50)
            .background(configuration.isPressed ? .pink.opacity(0.5) : .pink)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}


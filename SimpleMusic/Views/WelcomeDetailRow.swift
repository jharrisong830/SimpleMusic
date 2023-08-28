//
//  WelcomeDetailRow.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import SwiftUI

struct WelcomeDetailRow: View {
    let iconName: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: iconName)
                .font(.largeTitle)
                .foregroundColor(.pink)
            Spacer()
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    WelcomeDetailRow(iconName: "network", title: "Super Cool App", description: "This app is gonna do so much cool stuff just wait until you see!!!")
//}

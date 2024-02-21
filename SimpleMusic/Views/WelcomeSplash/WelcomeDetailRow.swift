//
//  WelcomeDetailRow.swift
//  Copyright (C) 2024  John Graham
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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

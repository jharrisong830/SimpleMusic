//
//  NoServicesView.swift
//  SimpleMusic
//
//  Created by John Graham on 9/30/23.
//

import SwiftUI

struct NoServicesView: View {
    @Binding var currentTab: SelectedTab
    
    var body: some View {
        VStack {
            Text("No music services are linked. You can add your music services from the Accounts tab.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding()
            Button {
                currentTab = .accounts
            } label: {
                Label("Go to Accounts", systemImage: "person.2.fill")
            }
            .buttonStyle(ProminentButtonStyle(color: .accentColor))
        }
    }
}



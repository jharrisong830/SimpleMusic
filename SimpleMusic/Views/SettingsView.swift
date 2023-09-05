//
//  SettingsView.swift
//  SimpleMusic
//
//  Created by John Graham on 7/28/23.
//

import SwiftUI
import SwiftData
import AuthenticationServices
import KeychainAccess
import HTTPTypes
import HTTPTypesFoundation
import MusicKit


struct SettingsView: View {
    @Query private var userSettings: [UserSettings]
    
    private let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
    private let spClient = "6dd07b58beda42a796654e331dcd99bd"
    private let redirect = "simple-music://"
    
    @State private var authRequestFailed = false
    
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    
    
    var body: some View {
        List {
            Section(header: Text("Spotify"), footer: Text("Connect to your Spotify account to transfer playlists between your music services.")) {
                if !userSettings[0].spotifyActive {
                    Button(action: {                        
                        let params = [
                            "response_type": "code",
                            "client_id": spClient,
                            "redirect_uri": redirect,
                            "scope": "playlist-read-private playlist-modify-private playlist-modify-public"
                        ]
                        let paramsURL = params.map {
                            "\($0)=\($1)"
                        }.joined(separator: "&")
                        let spURL = URL(string: "https://accounts.spotify.com/authorize?" + paramsURL)!
                        var spAuthCode: String? = nil
                        Task {
                            // authorization code
                            do {
                                let callbackWithAuthCode = try await webAuthenticationSession.authenticate(using: spURL, callbackURLScheme: "simple-music")
                                spAuthCode = callbackWithAuthCode.absoluteString.replacingOccurrences(of: "simple-music://?code=", with: "")
                            } catch {
                                authRequestFailed = true
                                print("Failed to get AUTHORIZATION CODE")
                                return
                            }
                            
                            // access and refresh codes
                            do {
                                try await SpotifyClient().initialAccessAuth(authCode: spAuthCode!)
                            } catch {
                                authRequestFailed = true
                                print("Failed to get ACCESS CODE")
                                return
                            }
                            userSettings[0].spotifyActive = true
                        }
                    }, label: {
                        Text("Connect Spotify Account")
                            .foregroundStyle(.green)
                    })
                    .alert("Spotify Authorization Failed", isPresented: $authRequestFailed, actions: {}, message: {Text("Failed to authorize your Spotify account. Please try again later.")})
                }
                else {
                    Text("Account authorized!")
                        .listRowBackground(Color.green)
                    Button {
                        Task {
                            try await SpotifyClient().getRefreshToken()
                        }
                    } label: {
                        Text("Try Refresh")
                    }
                    Button(action: {
                        do {
                            try keychain.removeAll()
                            userSettings[0].spotifyActive = false
                        } catch {
                            print("Couldn't sign out")
                        }
                    }, label: {
                        Text("Sign out")
                            .foregroundStyle(.red)
                    })
                }
            }
            Section(header: Text("Apple Music"), footer: Text("Connect your Apple Music account to transfer your music between services.")) {
                if MusicAuthorization.currentStatus == .notDetermined {
                    Button {
                        Task {
                            let status = await MusicAuthorization.request()
                            print(status.description)
                        }
                    } label: {
                        Text("Connect Apple Music Account")
                            .foregroundStyle(.pink)
                    }
                }
                else if MusicAuthorization.currentStatus == .authorized {
                    Text("Account authorized!")
                        .listRowBackground(Color.pink)
                }
                else {
                    Text("Couldn't access your Apple Music account. Please enable access in your device settings.")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

//#Preview {
//    SettingsView()
//}

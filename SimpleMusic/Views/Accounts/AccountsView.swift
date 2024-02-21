//
//  AccountsView.swift
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


struct AccountsView: View {
    @Query private var userSettings: [UserSettings]
    
    private let spClient = Bundle.main.infoDictionary?["SPOTIFY_CLIENT"] as? String
    private let redirect = "simple-music://"
    
    @State private var spAuthRequestFailed = false
//    @State private var ytAuthRequestFailed = false
    
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Spotify"), footer: Text("Connect to your Spotify account to transfer playlists between your music services.")) {
                    if !userSettings[0].spotifyActive {
                        Button {
                            withAnimation {
                                let params = [
                                    "response_type": "code",
                                    "client_id": spClient!,
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
                                        let callbackWithAuthCode = try await webAuthenticationSession.authenticate(using: spURL, callbackURLScheme: "simple-music", preferredBrowserSession: .ephemeral)
                                        spAuthCode = callbackWithAuthCode.absoluteString.replacingOccurrences(of: "simple-music://?code=", with: "")
                                    } catch {
                                        spAuthRequestFailed = true
                                        print("Failed to get AUTHORIZATION CODE")
                                        return
                                    }
                                    
                                    // access and refresh codes
                                    do {
                                        try await SpotifyClient.initialAccessAuth(authCode: spAuthCode!)
                                    } catch {
                                        spAuthRequestFailed = true
                                        print("Failed to get ACCESS CODE")
                                        return
                                    }
                                    userSettings[0].spotifyActive = true
                                }
                            }
                        } label: {
                            Text("Connect Spotify Account")
                                .foregroundStyle(Color("SpotifyGreen"))
                        }
                        .alert("Spotify Authorization Failed", isPresented: $spAuthRequestFailed, actions: {}, message: {Text("Failed to authorize your Spotify account. Please try again later.")})
                    }
                    else {
                        Text("Account authorized!")
                            .listRowBackground(Color("SpotifyGreen"))
                        Button {
                            withAnimation {
                                do {
                                    let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
                                    try keychain.remove("sp_access_token")
                                    try keychain.remove("sp_refresh_token")
                                    try keychain.remove("sp_access_expiration")
                                    userSettings[0].spotifyActive = false
                                } catch {
                                    print("Couldn't sign out")
                                }
                            }
                        } label: {
                            Text("Sign out")
                                .foregroundStyle(.red)
                        }
                    }
                }
                Section {
                    if MusicAuthorization.currentStatus == .notDetermined {
                        Button {
                            withAnimation {
                                print("fetching AM status...")
                                Task {
                                    let status = await MusicAuthorization.request()
                                    print(status.description)
                                }
                            }
                        } label: {
                            Text("Connect Apple Music Account")
                                .foregroundStyle(.pink)
                        }
                    }
                    else if MusicAuthorization.currentStatus == .authorized {
                        Text("Account authorized!")
                            .listRowBackground(Color.pink)
                        Button {
                            withAnimation {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }
                        } label: {
                            Text("Edit Access in Settings")
                        }
                    }
                    else {
                        Text("Apple Music Access Denied")
                            .foregroundStyle(.secondary)
                        Button {
                            withAnimation {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }
                        } label: {
                            Text("Edit Access in Settings")
                        }
                    }
                } header: {
                    Text("Apple Music")
                } footer: {
                    Text("Connect your Apple Music account to transfer your music between services.")
                }
                
                
//                Section(header: Text("YouTube"), footer: Text("Connect to your YouTube account to transfer playlists between your music services.")) {
//                    if !(userSettings[0].youtubeActive ?? false) {
//                        Button {
//                            withAnimation {
//                                let api_key = Bundle.main.infoDictionary?["GOOGLE_CLIENT"] as? String
//        
//                                let params = [
//                                    "response_type": "code",
//                                    "client_id": api_key!,
//                                    "redirect_uri": "com.googleusercontent.apps.246281019333-flnmf3geqs3h7lvequcisei2b647vktb:/simple-music",
//                                    "scope": "https://www.googleapis.com/auth/youtube"
//                                ]
//                                let paramsURL = params.map {
//                                    "\($0)=\($1)"
//                                }.joined(separator: "&")
//                                let ytURL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?" + paramsURL)!
//                                var ytAuthCode: String? = nil
//                                Task {
//                                    // authorization code
//                                    do {
//                                        let callbackWithAuthCode = try await webAuthenticationSession.authenticate(using: ytURL, callbackURLScheme: "com.googleusercontent.apps.246281019333-flnmf3geqs3h7lvequcisei2b647vktb", preferredBrowserSession: .ephemeral)
//                                        let componentArray = callbackWithAuthCode.absoluteString.replacingOccurrences(of: "com.googleusercontent.apps.246281019333-flnmf3geqs3h7lvequcisei2b647vktb:/simple-music?code=", with: "").components(separatedBy: "&")
//                                        ytAuthCode = componentArray[0]
//                                    } catch {
//                                        ytAuthRequestFailed = true
//                                        print("Failed to get AUTHORIZATION CODE")
//                                        return
//                                    }
//        
//                                    // access and refresh codes
//                                    do {
//                                        try await YouTubeClient.initialAuthAccess(authCode: ytAuthCode!)
//                                    } catch {
//                                        ytAuthRequestFailed = true
//                                        print("Failed to get ACCESS CODE")
//                                        return
//                                    }
//                                    userSettings[0].youtubeActive = true
//                                }
//                            }
//                        } label: {
//                            Text("Connect YouTube Account")
//                                .foregroundStyle(.red)
//                        }
//                        .alert("YouTube Authorization Failed", isPresented: $ytAuthRequestFailed, actions: {}, message: {Text("Failed to authorize your YouTube account. Please try again later.")})
//                    }
//                    else {
//                        Text("Account authorized!")
//                            .listRowBackground(Color.red)
//                        Button {
//                            withAnimation {
//                                do {
//                                    let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
//                                    try keychain.remove("sp_access_token")
//                                    try keychain.remove("sp_refresh_token")
//                                    try keychain.remove("sp_access_expiration")
//                                    userSettings[0].youtubeActive = false
//                                } catch {
//                                    print("Couldn't sign out")
//                                }
//                            }
//                        } label: {
//                            Text("Sign out")
//                                .foregroundStyle(.red)
//                        }
//                    }
//                }
            }
            .navigationTitle("Accounts")
        }
    }
}

//#Preview {
//    SettingsView()
//}

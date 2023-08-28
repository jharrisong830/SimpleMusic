//
//  SettingsView.swift
//  SimpleMusic
//
//  Created by John Graham on 7/28/23.
//

import SwiftUI
import AuthenticationServices
import KeychainAccess
import HTTPTypes
import HTTPTypesFoundation


extension HTTPField.Name {
    static let contentType = Self("Content-Type")!
    static let authorization = Self("Authorization")!
}


struct SettingsView: View {
    let userDefaults = UserDefaults.standard
    
    private let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
    private let spClient = "6dd07b58beda42a796654e331dcd99bd"
    private let redirect = "simple-music://"
    
    @State private var authenticatedJustNow = false
    @State private var authRequestFailed = false
    
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    
    
    var body: some View {
        List {
            Section(header: Text("Accounts"), footer: Text("Connect to your Spotify account to transfer playlists between your music services.")) {
                if keychain["access_token"] == nil && !authenticatedJustNow {
                    Button(action: {
                        let api_key = Bundle.main.infoDictionary?["API_KEY"] as? String
                        
                        let params = [
                            "response_type": "code",
                            "client_id": spClient,
                            "scope": "playlist-read-private",
                            "redirect_uri": redirect
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
                            var newRequest = HTTPRequest(method: .post, url: URL(string: "https://accounts.spotify.com/api/token")!)
                            newRequest.headerFields[.contentType] = "application/x-www-form-urlencoded"
                            let accessParams = "grant_type=authorization_code&code=\(spAuthCode!)&redirect_uri=\(redirect)"
//                            let accessURL = URL(string: "https://accounts.spotify.com/api/token")
//                            var accessReq = URLRequest(url: accessURL!)
//                            accessReq.httpMethod = "POST"
//                            accessReq.httpBody = accessParams.data(using: .utf8)
//                            accessReq.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                            let apiKeys = "\(spClient):\(api_key!)"
                            let encodedKeys = Data(apiKeys.data(using: .utf8)!).base64EncodedString()
                            newRequest.headerFields[.authorization] = "Basic \(encodedKeys)"
//                            accessReq.setValue("Basic \(encodedKeys)", forHTTPHeaderField: "Authorization")
                            let (data, _) = try await URLSession.shared.upload(for: newRequest, from: accessParams.data(using: .utf8)!)
                            
                            
//                            let (data, response) = try await URLSession.shared.data(for: accessReq)
//                            guard response is HTTPURLResponse else {
//                                print("URL response error")
//                                return
//                            }
                            let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
                            
                            // set codes in keychain
                            try keychain.removeAll()
                            keychain["user_authorization"] = spAuthCode
                            keychain["access_token"] = jsonData["access_token"] as? String
                            keychain["refresh_token"] = jsonData["refresh_token"] as? String
                            keychain["access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
                            authenticatedJustNow = true
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
                    Button(action: {
                        do {
                            try keychain.removeAll()
                            authenticatedJustNow = false
                        } catch {
                            print("Couldn't sign out")
                        }
                    }, label: {
                        Text("Sign out")
                            .foregroundStyle(.red)
                    })
                }
            }
        }
        .navigationTitle("Settings")
    }
}

//#Preview {
//    SettingsView()
//}

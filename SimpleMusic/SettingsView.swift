//
//  SettingsView.swift
//  SimpleMusic
//
//  Created by John Graham on 7/28/23.
//

import SwiftUI
import AuthenticationServices
import KeychainAccess

struct SettingsView: View {
    private let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
    private let spClient = "af3b24f07e0e464889fdcd33bbf8b7d6"
    private let redirect = "simple-music://"
    
    @State private var authRequestFailed = false
    
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    
    
    var body: some View {
        List {
            Section(header: Text("Accounts"), footer: Text("Connect to your Spotify account to transfer playlists between your music services.")) {
                if keychain["access_token"] == nil {
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
                        let spURL = URL(string: "https://accounts.spotify.com/authorize?" + paramsURL)
                        Task {
                            do {
                                // Perform the authentication and await the result.
                                let urlWithToken = try await webAuthenticationSession.authenticate(
                                    using: spURL!,
                                    callbackURLScheme: "simple-music"
                                )
                                guard let urlComponents = URLComponents(url: urlWithToken, resolvingAgainstBaseURL: false) else {
                                    authRequestFailed = true
                                    return
                                }
                                guard let spAuthCode = urlComponents.queryItems?.first(where: {$0.name == "code"}) else {
                                    authRequestFailed = true
                                    return
                                }
                                
                                // get access and refresh code
                                let accessParams = "grant_type=authorization_code&code=\(spAuthCode.value!)&redirect_uri=\(redirect)"
                                let accessURL = URL(string: "https://accounts.spotify.com/api/token")
                                var accessReq = URLRequest(url: accessURL!)
                                accessReq.httpMethod = "POST"
                                accessReq.httpBody = accessParams.data(using: .utf8) //try JSONEncoder().encode(accessParams)
                                accessReq.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                                let apiKeys = "\(spClient):\(api_key!)"
                                let encodedKeys = Data(apiKeys.data(using: .utf8)!).base64EncodedString()
                                accessReq.setValue("Basic \(encodedKeys)", forHTTPHeaderField: "Authorization")
                                let task = URLSession.shared.dataTask(with: accessReq) { data, response, error in
                                    guard
                                        let data = data,
                                        let response = response as? HTTPURLResponse,
                                        error == nil
                                    else {                                                               // check for fundamental networking error
                                        print("error", error ?? URLError(.badServerResponse))
                                        return
                                    }
                                    guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                                        print("statusCode should be 2xx, but is \(response.statusCode)")
                                        print("response = \(response)")
                                        do {
                                            print("data = \(try JSONSerialization.jsonObject(with: data))")
                                            return
                                        } catch {
                                            return
                                        }
                                    }
                                    do {
                                        let jsonResponse = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
                                        keychain["access_token"] = jsonResponse["access_token"] as? String
                                        keychain["refresh_token"] = jsonResponse["refresh_token"] as? String
                                    } catch {
                                        authRequestFailed = true
                                    }
                                }

                                task.resume()
                            } catch {
                                print("cancelled")
                            }
                        }
                    }, label: {
                        Text("Connect Spotify Account")
                            .foregroundStyle(.green)
                    })
                    .alert("Spotify Authorization Failed", isPresented: $authRequestFailed, actions: {}, message: {Text("Failed to authorize your Spotify account. Please try again later.")})
                }
                else {
                    Text("Account authorized!")
                        .background(.green)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}

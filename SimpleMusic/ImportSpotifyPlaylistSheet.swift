//
//  ImportSpotifyPlaylistSheet.swift
//  SimpleMusic
//
//  Created by John Graham on 8/3/23.
//

import SwiftUI
import KeychainAccess

struct ImportSpotifyPlaylistSheet: View {
    @Binding var isPresented: Bool
    
    @State private var totalPlaylists = -1
    
    func getSpotifyPlaylists() async -> Int {
        var total = -1
        
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        if keychain["access_token"] == nil {
            return total
        }
        let playlistURL = URL(string: "https://api.spotify.com/v1/me/playlists")
        var playlistReq = URLRequest(url: playlistURL!)
        playlistReq.httpMethod = "GET"
        playlistReq.setValue("Bearer \(keychain["access_token"]!)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: playlistReq) { data, response, error in
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
        }
        task.resume()
        do {
            let taskResponse = try await URLSession.shared.data(for: playlistReq)
            let jsonData = try JSONSerialization.jsonObject(with: taskResponse.0) as! Dictionary<String, Any>
            total = jsonData["total"]! as! Int
        } catch {
            print("error")
        }
        return total
    }
    
    var body: some View {
        VStack {
            Spacer()
            if totalPlaylists == -1 {
                Button(action: {
                    Task {
                        totalPlaylists = await getSpotifyPlaylists()
                    }
                }, label: {
                    Text("Get Playlists")
                })
                .buttonStyle(ProminentButtonStyle())
            }
            else {
                Text("Found \(totalPlaylists) playlists!")
            }
            Spacer()
            Button(action: {
                isPresented = false
            }, label: {
                Text("Done")
            })
            .buttonStyle(ProminentButtonStyle())
            Spacer()
        }
    }
}

#Preview {
    ImportSpotifyPlaylistSheet(isPresented: .constant(true))
}

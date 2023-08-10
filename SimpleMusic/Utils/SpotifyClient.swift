//
//  SpotifyClient.swift
//  SimpleMusic
//
//  Created by John Graham on 8/3/23.
//

import Foundation
import KeychainAccess


class SpotifyClient {
    private let spClient = "af3b24f07e0e464889fdcd33bbf8b7d6"
    private let redirect = "simple-music://"
    
    
    
    
    func checkRefresh() async throws { //TODO: doesnt work lol
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        let api_key = Bundle.main.infoDictionary?["API_KEY"] as? String
        let expiryTime = Double(keychain["access_expiration"]!)!
        
        if Date.now.timeIntervalSince1970 > expiryTime {
            // use refresh token to get new access token
            let accessParams = "grant_type=refresh_token&refresh_token=\(keychain["refresh_token"]!)&redirect_uri=\(redirect)"
            let accessURL = URL(string: "https://accounts.spotify.com/api/token")
            var accessReq = URLRequest(url: accessURL!)
            accessReq.httpMethod = "POST"
            accessReq.httpBody = accessParams.data(using: .utf8)
            accessReq.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let apiKeys = "\(spClient):\(api_key!)"
            let encodedKeys = Data(apiKeys.data(using: .utf8)!).base64EncodedString()
            accessReq.setValue("Basic \(encodedKeys)", forHTTPHeaderField: "Authorization")
            let (data, response) = try await URLSession.shared.data(for: accessReq)
            guard response is HTTPURLResponse else {
                print("URL response error")
                return
            }
            let jsonData = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
            
            // set codes in keychain
            keychain["access_token"] = jsonData["access_token"] as? String
            keychain["access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
        }
    }
    
    
    func getPrivatePlaylists() async throws -> [PlaylistData] {
        var allPlaylists: [PlaylistData] = []
        
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        do {
            try await self.checkRefresh()
        } catch {
            print("error getting refresh")
            return []
        }
        
        var playlistURL: String? = "https://api.spotify.com/v1/me/playlists?offset=0&limit=50"
        
        
        repeat {
            var playlistReq = URLRequest(url: URL(string: playlistURL!)!)
            playlistReq.httpMethod = "GET"
            playlistReq.setValue("Bearer \(keychain["access_token"]!)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: playlistReq)
            
            guard response is HTTPURLResponse else {
                print("URL response error")
                return []
            }
            
            let jsonData = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
            
            allPlaylists.append(contentsOf: (jsonData["items"] as! [Dictionary<String, Any>]).map {
                PlaylistData(name: $0["name"] as! String, amid: "", spid: $0["id"] as! String, songs: [], coverImage: ($0["images"] as! [Dictionary<String, Any>])[0]["url"] as? String)
            })
            playlistURL = jsonData["next"] as? String
        } while playlistURL != nil
        
        return allPlaylists
    }
    
    
}

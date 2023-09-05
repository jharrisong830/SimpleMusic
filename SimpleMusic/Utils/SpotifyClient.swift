//
//  SpotifyClient.swift
//  SimpleMusic
//
//  Created by John Graham on 8/3/23.
//

import Foundation
import KeychainAccess
import HTTPTypes
import HTTPTypesFoundation


extension HTTPField.Name {
    static let contentType = Self("Content-Type")!
    static let authorization = Self("Authorization")!
}


class SpotifyClient {
    private let spClient = "6dd07b58beda42a796654e331dcd99bd"
    private let redirect = "simple-music://"
    
    
    
    func initialAccessAuth(authCode: String) async throws {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        let api_key = Bundle.main.infoDictionary?["API_KEY"] as? String
        
        var newRequest = HTTPRequest(method: .post, url: URL(string: "https://accounts.spotify.com/api/token")!)
        newRequest.headerFields[.contentType] = "application/x-www-form-urlencoded"
        let accessParams = "grant_type=authorization_code&code=\(authCode)&redirect_uri=\(redirect)"

        let apiKeys = "\(spClient):\(api_key!)"
        let encodedKeys = Data(apiKeys.data(using: .utf8)!).base64EncodedString()
        newRequest.headerFields[.authorization] = "Basic \(encodedKeys)"
        
        let (data, _) = try await URLSession.shared.upload(for: newRequest, from: accessParams.data(using: .utf8)!)
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        
        // set codes in keychain
        try keychain.removeAll()
        keychain["access_token"] = jsonData["access_token"] as? String
        keychain["refresh_token"] = jsonData["refresh_token"] as? String
        keychain["access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
    }
    
    
    func checkRefresh() -> Bool {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        guard let expiryTime = Double(keychain["access_expiration"]!) else {
            return true
        }
        return Date.now.timeIntervalSince1970 > expiryTime // returns true if key needs to be refreshed, false if okay
    }
    
    func getRefreshToken() async throws {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        let api_key = Bundle.main.infoDictionary?["API_KEY"] as? String
        
        let accessParams = "grant_type=refresh_token&refresh_token=\(keychain["refresh_token"]!)&redirect_uri=\(redirect)"
        var newRequest = HTTPRequest(method: .post, url: URL(string: "https://accounts.spotify.com/api/token")!)
        newRequest.headerFields[.contentType] = "application/x-www-form-urlencoded"
        
        let apiKeys = "\(spClient):\(api_key!)"
        let encodedKeys = Data(apiKeys.data(using: .utf8)!).base64EncodedString()
        newRequest.headerFields[.authorization] = "Basic \(encodedKeys)"
        
        let (data, _) = try await URLSession.shared.upload(for: newRequest, from: accessParams.data(using: .utf8)!)
        
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        
        // set codes in keychain
        keychain["access_token"] = jsonData["access_token"] as? String
        keychain["access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
    }
    
    
    func getUserID() async throws -> String {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var userReq = HTTPRequest(method: .get, url: URL(string: "https://api.spotify.com/v1/me")!)
        userReq.headerFields[.authorization] = "Bearer \(keychain["access_token"]!)"
        
        let (data, _) = try await URLSession.shared.data(for: userReq)
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        
        return jsonData["id"] as! String
    }
    
    func getPrivatePlaylists() async throws -> [PlaylistData] {
        var allPlaylists: [PlaylistData] = []
        
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
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
            
            let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
            
            allPlaylists.append(contentsOf: (jsonData["items"] as! [JSONObject]).map {
                PlaylistData(name: $0["name"] as! String, amid: "", spid: $0["id"] as! String, coverImage: ($0["images"] as! [JSONObject])[0]["url"] as? String, sourcePlatform: .spotify)
            })
            playlistURL = jsonData["next"] as? String
        } while playlistURL != nil
        
        return allPlaylists
    }
    
    
    func getPlaylistSongs(playlistID: String) async throws -> [SongData] {
        var allSongs: [SongData] = []
        
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var songURL: String? = "https://api.spotify.com/v1/playlists/\(playlistID)/tracks?offset=0&limit=50"
        
        
        repeat {
            var songReq = URLRequest(url: URL(string: songURL!)!)
            songReq.httpMethod = "GET"
            songReq.setValue("Bearer \(keychain["access_token"]!)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: songReq)
            
            guard response is HTTPURLResponse else {
                print("URL response error")
                return []
            }
            let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
            
            allSongs.append(contentsOf: (jsonData["items"] as! [JSONObject]).map {
                SongData(name: ($0["track"] as! JSONObject)["name"] as! String,
                         artists: (($0["track"] as! JSONObject)["artists"] as! [JSONObject]).map({$0["name"] as! String}),
                         albumName: (($0["track"] as! JSONObject)["album"] as! JSONObject)["name"] as! String,
                         albumArtists: ((($0["track"] as! JSONObject)["album"] as! JSONObject)["artists"] as! [JSONObject]).map({$0["name"] as! String}),
                         isrc: (($0["track"] as! JSONObject)["external_ids"] as! JSONObject)["isrc"] as! String,
                         amid: "",
                         spid: ($0["track"] as! JSONObject)["id"] as! String,
                         coverImage: ((($0["track"] as! JSONObject)["album"] as! JSONObject)["images"] as! [JSONObject])[2]["url"] as? String)
            })
            songURL = jsonData["next"] as? String
        } while songURL != nil
        
        return allSongs
    }
    
    
    
    func getSongMatches(playlist: PlaylistData) async throws -> [SongData] {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        let songs = try await AppleMusicClient().getPlaylistSongs(playlistID: playlist.amid)
        
        for song in songs {
            var searchRequest = HTTPRequest(method: .get, url: URL(string: "https://api.spotify.com/v1/search?q=isrc:\(song.isrc)&type=track")!)
            searchRequest.headerFields[.authorization] = "Bearer \(keychain["access_token"]!)"
            
            let (data, _) = try await URLSession.shared.data(for: searchRequest)
            let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
            if (jsonData["tracks"] as! JSONObject)["total"] as! Int != 0 {
                song.spid = ((jsonData["tracks"] as! JSONObject)["items"] as! [JSONObject])[0]["id"] as! String
                song.coverImage = ((((jsonData["tracks"] as! JSONObject)["items"] as! [JSONObject])[0]["album"] as! JSONObject)["images"] as! [JSONObject])[2]["url"] as? String
                song.matchState = .successful
            }
            else {
                song.matchState = .failed
            }
        }
        return songs
    }
    
    
    func searchSpotifyCatalog(searchText: String) async throws -> [SongData] {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var searchRequest = HTTPRequest(method: .get, url: URL(string: "https://api.spotify.com/v1/search?q=\(searchText)&type=track")!)
        searchRequest.headerFields[.authorization] = "Bearer \(keychain["access_token"]!)"
        
        let (data, _) = try await URLSession.shared.data(for: searchRequest)
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        
        let searchResults = (jsonData["tracks"] as! JSONObject)["items"] as! [JSONObject]
        
        return searchResults.map {
            SongData(name: $0["name"] as! String,
                     artists: ($0["artists"] as! [JSONObject]).map({$0["name"] as! String}),
                     albumName: ($0["album"] as! JSONObject)["name"] as! String,
                     albumArtists: (($0["album"] as! JSONObject)["artists"] as! [JSONObject]).map({$0["name"] as! String}),
                     isrc: ($0["external_ids"] as! JSONObject)["isrc"] as! String,
                     amid: "",
                     spid: $0["id"] as! String,
                     coverImage: (($0["album"] as! JSONObject)["images"] as! [JSONObject])[2]["url"] as? String)
        }
    }
    
    
    func createNewPlaylist(name: String, description: String?) async throws -> String {
        let playlistData = [
            "name": name,
            "description": description
        ]
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        let userID = try await getUserID()
        
        var playlistReq = HTTPRequest(method: .post, url: URL(string: "https://api.spotify.com/v1/users/\(userID)/playlists")!)
        playlistReq.headerFields[.authorization] = "Bearer \(keychain["access_token"]!)"
        
        let (data, _) = try await URLSession.shared.upload(for: playlistReq, from: try JSONSerialization.data(withJSONObject: playlistData))
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        print(jsonData)
        
        return jsonData["id"] as! String
    }
    
    func addSongsToPlaylist(spotifyPlaylistID: String, songs: [SongData]) async throws {
        let URIBody: [String: Any] = [
            "uris": songs.map({"spotify:track:\($0.spid)"}),
            "position": 0
        ]
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var playlistReq = HTTPRequest(method: .post, url: URL(string: "https://api.spotify.com/v1/playlists/\(spotifyPlaylistID)/tracks")!)
        playlistReq.headerFields[.authorization] = "Bearer \(keychain["access_token"]!)"
        
        let (data, _) = try await URLSession.shared.upload(for: playlistReq, from: try JSONSerialization.data(withJSONObject: URIBody))
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        print("WE DID IT JOE")
        print(jsonData)
    }
    
}

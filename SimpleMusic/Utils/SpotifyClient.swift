//
//  SpotifyClient.swift
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

import Foundation
import KeychainAccess
import HTTPTypes
import HTTPTypesFoundation


extension HTTPField.Name {
    static let contentType = Self("Content-Type")!
    static let authorization = Self("Authorization")!
}


class SpotifyClient {
    static private let spClient = Bundle.main.infoDictionary?["SPOTIFY_CLIENT"] as? String
    static private let redirect = "simple-music://"
    
    
    
    static func initialAccessAuth(authCode: String) async throws {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        let api_key = Bundle.main.infoDictionary?["API_KEY"] as? String
        
        var newRequest = HTTPRequest(method: .post, url: URL(string: "https://accounts.spotify.com/api/token")!)
        newRequest.headerFields[.contentType] = "application/x-www-form-urlencoded"
        let accessParams = "grant_type=authorization_code&code=\(authCode)&redirect_uri=\(redirect)"

        let apiKeys = "\(spClient!):\(api_key!)"
        let encodedKeys = Data(apiKeys.data(using: .utf8)!).base64EncodedString()
        newRequest.headerFields[.authorization] = "Basic \(encodedKeys)"
        
        let (data, _) = try await URLSession.shared.upload(for: newRequest, from: accessParams.data(using: .utf8)!)
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        
        // set codes in keychain
        try keychain.remove("sp_access_token")
        try keychain.remove("sp_refresh_token")
        try keychain.remove("sp_access_expiration")
        keychain["sp_access_token"] = jsonData["access_token"] as? String
        keychain["sp_refresh_token"] = jsonData["refresh_token"] as? String
        keychain["sp_access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
    }
    
    
    static func checkRefresh() -> Bool {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        guard let expiryTimeString = keychain["sp_access_expiration"] else {
            return true
        }
        let expiryTime = Double(expiryTimeString)!
        return Date.now.timeIntervalSince1970 > expiryTime // returns true if key needs to be refreshed, false if okay
    }
    
    static func getRefreshToken() async throws {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        let api_key = Bundle.main.infoDictionary?["API_KEY"] as? String
        
        let accessParams = "grant_type=refresh_token&refresh_token=\(keychain["sp_refresh_token"]!)&redirect_uri=\(redirect)"
        var newRequest = HTTPRequest(method: .post, url: URL(string: "https://accounts.spotify.com/api/token")!)
        newRequest.headerFields[.contentType] = "application/x-www-form-urlencoded"
        
        let apiKeys = "\(spClient!):\(api_key!)"
        let encodedKeys = Data(apiKeys.data(using: .utf8)!).base64EncodedString()
        newRequest.headerFields[.authorization] = "Basic \(encodedKeys)"
        
        let (data, _) = try await URLSession.shared.upload(for: newRequest, from: accessParams.data(using: .utf8)!)
        
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        
        // set codes in keychain
        keychain["sp_access_token"] = jsonData["access_token"] as? String
        keychain["sp_access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
    }
    
    
    static func getUserID() async throws -> String {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var userReq = HTTPRequest(method: .get, url: URL(string: "https://api.spotify.com/v1/me")!)
        userReq.headerFields[.authorization] = "Bearer \(keychain["sp_access_token"]!)"
        
        let (data, _) = try await URLSession.shared.data(for: userReq)
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        
        return jsonData["id"] as! String
    }
    
    static func getPrivatePlaylists() async throws -> [PlaylistData] {
        var allPlaylists: [PlaylistData] = []
        
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var playlistURL: String? = "https://api.spotify.com/v1/me/playlists?offset=0&limit=50"
        let userID = try await getUserID()
        
        
        repeat {
            var playlistReq = URLRequest(url: URL(string: playlistURL!)!)
            playlistReq.httpMethod = "GET"
            playlistReq.setValue("Bearer \(keychain["sp_access_token"]!)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: playlistReq)
            
            guard response is HTTPURLResponse else {
                print("URL response error")
                return []
            }
            
            let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
            
            allPlaylists.append(contentsOf: (jsonData["items"] as! [JSONObject]).filter {
                ($0["owner"] as! JSONObject)["id"] as! String == userID
            }.map {
                PlaylistData(name: $0["name"] as! String, platform: .spotify, platformID: $0["id"] as! String, platformURL: URL(string: ($0["external_urls"] as! JSONObject)["spotify"] as! String), coverImage: URL(string: ($0["images"] as! [JSONObject])[0]["url"] as! String))
            })
            playlistURL = jsonData["next"] as? String
        } while playlistURL != nil
        
        return allPlaylists
    }
    
    
    static func getPlaylistSongs(playlist: PlaylistData) async throws -> [SongData] {
        var allSongs: [SongData] = []
        
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var songURL: String? = "https://api.spotify.com/v1/playlists/\(playlist.platformID)/tracks?offset=0&limit=50"
        var count = 0
        
        repeat {
            var songReq = URLRequest(url: URL(string: songURL!)!)
            songReq.httpMethod = "GET"
            songReq.setValue("Bearer \(keychain["sp_access_token"]!)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: songReq)
            
            guard response is HTTPURLResponse else {
                print("URL response error")
                return []
            }
            let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
            
            for obj in jsonData["items"] as! [JSONObject] {
                allSongs.append(SongData(name: (obj["track"] as! JSONObject)["name"] as! String,
                                         artists: ((obj["track"] as! JSONObject)["artists"] as! [JSONObject]).map({$0["name"] as! String}),
                                         albumName: ((obj["track"] as! JSONObject)["album"] as! JSONObject)["name"] as! String,
                                         albumArtists: (((obj["track"] as! JSONObject)["album"] as! JSONObject)["artists"] as! [JSONObject]).map({$0["name"] as! String}),
                                         isrc: ((obj["track"] as! JSONObject)["external_ids"] as! JSONObject)["isrc"] as! String,
                                         platform: .spotify,
                                         platformID: (obj["track"] as! JSONObject)["id"] as! String,
                                         platformURL: URL(string: ((obj["track"] as! JSONObject)["external_urls"] as! JSONObject)["spotify"] as! String),
                                         coverImage: URL(string: (((obj["track"] as! JSONObject)["album"] as! JSONObject)["images"] as! [JSONObject])[2]["url"] as! String),
                                         playlist: nil,
                                         index: count))
                count += 1
            }
            songURL = jsonData["next"] as? String
        } while songURL != nil
        
        return allSongs
    }
    
    
    
    static func getSongMatches(playlist: PlaylistData) async throws -> [SongData] {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var newSongs: [SongData] = []
        
        for song in playlist.songs.sorted(by: { $0.index < $1.index }) {
            if song == SongData.nilSong {
                newSongs.append(SongData(name: song.name, artists: song.artists, albumName: song.albumName, albumArtists: song.albumArtists, isrc: song.isrc, platform: song.platform, platformID: song.platformID, platformURL: song.platformURL, coverImage: song.coverImage, playlist: nil, index: song.index, matchState: .failed))
            }
            else {
                var searchRequest = HTTPRequest(method: .get, url: URL(string: "https://api.spotify.com/v1/search?q=isrc:\(song.isrc)&type=track")!)
                searchRequest.headerFields[.authorization] = "Bearer \(keychain["sp_access_token"]!)"
                
                let (data, _) = try await URLSession.shared.data(for: searchRequest)
                let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
                if (jsonData["tracks"] as! JSONObject)["total"] as! Int != 0 {
                    newSongs.append(SongData(name: song.name,
                                             artists: song.artists,
                                             albumName: song.albumName,
                                             albumArtists: song.albumArtists,
                                             isrc: song.isrc,
                                             platform: .spotify,
                                             platformID: ((jsonData["tracks"] as! JSONObject)["items"] as! [JSONObject])[0]["id"] as! String,
                                             platformURL: URL(string: (((jsonData["tracks"] as! JSONObject)["items"] as! [JSONObject])[0]["external_urls"] as! JSONObject)["spotify"] as! String),
                                             coverImage: URL(string: ((((jsonData["tracks"] as! JSONObject)["items"] as! [JSONObject])[0]["album"] as! JSONObject)["images"] as! [JSONObject])[2]["url"] as! String),
                                             playlist: nil,
                                             index: song.index,
                                             matchState: .successful))
                }
                else {
                    newSongs.append(SongData(name: song.name, artists: song.artists, albumName: song.albumName, albumArtists: song.albumArtists, isrc: song.isrc, platform: song.platform, platformID: song.platformID, platformURL: song.platformURL, coverImage: song.coverImage, playlist: nil, index: song.index, matchState: .failed))
                }
            }
        }
        return newSongs
    }
    
    
    static func searchSpotifyCatalog(searchText: String) async throws -> [SongData] {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var searchRequest = HTTPRequest(method: .get, url: URL(string: "https://api.spotify.com/v1/search?q=\(searchText)&type=track")!)
        searchRequest.headerFields[.authorization] = "Bearer \(keychain["sp_access_token"]!)"
        
        let (data, _) = try await URLSession.shared.data(for: searchRequest)
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        
        let searchResults = (jsonData["tracks"] as! JSONObject)["items"] as! [JSONObject]
        
        return searchResults.map {
            SongData(name: $0["name"] as! String,
                     artists: ($0["artists"] as! [JSONObject]).map({$0["name"] as! String}),
                     albumName: ($0["album"] as! JSONObject)["name"] as! String,
                     albumArtists: (($0["album"] as! JSONObject)["artists"] as! [JSONObject]).map({$0["name"] as! String}),
                     isrc: ($0["external_ids"] as! JSONObject)["isrc"] as! String,
                     platform: .spotify,
                     platformID: $0["id"] as! String,
                     platformURL: URL(string: ($0["external_urls"] as! JSONObject)["spotify"] as! String),
                     coverImage: URL(string: (($0["album"] as! JSONObject)["images"] as! [JSONObject])[2]["url"] as! String),
                     playlist: nil,
                     index: 0)
        }
    }
    
    
    static func createNewPlaylist(name: String, description: String?) async throws -> String {
        let playlistData = [
            "name": name,
            "description": description ?? "transferred with <3 by Simple Music"
        ]
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        let userID = try await getUserID()
        
        var playlistReq = HTTPRequest(method: .post, url: URL(string: "https://api.spotify.com/v1/users/\(userID)/playlists")!)
        playlistReq.headerFields[.authorization] = "Bearer \(keychain["sp_access_token"]!)"
        
        let (data, _) = try await URLSession.shared.upload(for: playlistReq, from: try JSONSerialization.data(withJSONObject: playlistData))
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        print(jsonData)
        
        return jsonData["id"] as! String
    }
    
    static func addSongsToPlaylist(spotifyPlaylistID: String, songs: [SongData]) async throws {
        let URIBody: [String: Any] = [
            "uris": songs.sorted(by: { $0.index < $1.index }).map({"spotify:track:\($0.platformID)"}),
            "position": 0
        ]
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        
        var playlistReq = HTTPRequest(method: .post, url: URL(string: "https://api.spotify.com/v1/playlists/\(spotifyPlaylistID)/tracks")!)
        playlistReq.headerFields[.authorization] = "Bearer \(keychain["sp_access_token"]!)"
        
        let (data, _) = try await URLSession.shared.upload(for: playlistReq, from: try JSONSerialization.data(withJSONObject: URIBody))
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        print("WE DID IT JOE")
        print(jsonData)
    }
    
}

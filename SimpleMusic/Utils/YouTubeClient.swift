//
//  YouTubeClient.swift
//  SimpleMusic
//
//  Created by John Graham on 9/20/23.
//

//import Foundation
//import KeychainAccess
//import HTTPTypes
//import HTTPTypesFoundation
//
//
//class YouTubeClient {
//    static func initialAuthAccess(authCode: String) async throws {
//        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
//        let api_key = Bundle.main.infoDictionary?["GOOGLE_CLIENT"] as? String
//    
//        var newRequest = HTTPRequest(method: .post, url: URL(string: "https://oauth2.googleapis.com/token")!)
//        newRequest.headerFields[.contentType] = "application/x-www-form-urlencoded"
//        let accessParams = "client_id=\(api_key!)&code=\(authCode)&grant_type=authorization_code&redirect_uri=com.googleusercontent.apps.246281019333-flnmf3geqs3h7lvequcisei2b647vktb:/simple-music&response_type=code&scope=https://www.googleapis.com/auth/youtube"
//        
//        let (data, _) = try await URLSession.shared.upload(for: newRequest, from: accessParams.data(using: .utf8)!)
//        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
//        
//        // set codes in keychain
//        try keychain.remove("yt_access_token")
//        try keychain.remove("yt_refresh_token")
//        try keychain.remove("yt_access_expiration")
//        keychain["yt_access_token"] = jsonData["access_token"] as? String
//        keychain["yt_refresh_token"] = jsonData["refresh_token"] as? String
//        keychain["yt_access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
//    }
//    
//    static func checkRefresh() -> Bool {
//        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
//        guard let expiryTimeString = keychain["yt_access_expiration"] else {
//            return true
//        }
//        let expiryTime = Double(expiryTimeString)!
//        return Date.now.timeIntervalSince1970 > expiryTime // returns true if key needs to be refreshed, false if okay
//    }
//    
//    static func getRefreshToken() async throws {
//        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
//        let api_key = Bundle.main.infoDictionary?["GOOGLE_CLIENT"] as? String
//        
//        let accessParams = "grant_type=refresh_token&refresh_token=\(keychain["yt_refresh_token"]!)&client_id=\(api_key!)"
//        var newRequest = HTTPRequest(method: .post, url: URL(string: "https://oauth2.googleapis.com/token")!)
//        newRequest.headerFields[.contentType] = "application/x-www-form-urlencoded"
//        
//        let (data, _) = try await URLSession.shared.upload(for: newRequest, from: accessParams.data(using: .utf8)!)
//        
//        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
//        
//        // set codes in keychain
//        keychain["yt_access_token"] = jsonData["access_token"] as? String
//        keychain["yt_access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
//    }
//    
//    static func getPlaylists() async throws -> [PlaylistData] {
//        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
//        let api_key = Bundle.main.infoDictionary?["GOOGLE_CLIENT"] as? String
//        
//        var allPlaylists: [PlaylistData] = []
//        
//        var playlistReq: HTTPRequest? = HTTPRequest(method: .get, url: URL(string: "https://youtube.googleapis.com/youtube/v3/playlists?part=snippet%2CcontentDetails&maxResults=50&mine=true&key=\(api_key!)")!)
//        playlistReq!.headerFields[.authorization] = "Bearer \(keychain["yt_access_token"]!)"
//        
//        repeat {
//            let (data, _) = try await URLSession.shared.data(for: playlistReq!)
//            let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
//            
//            allPlaylists.append(contentsOf: (jsonData["items"] as! [JSONObject]).map {
//                PlaylistData(name: (($0["snippet"] as! JSONObject)["localized"] as! JSONObject)["title"] as! String, amid: "", spid: "", ytid: $0["id"] as? String, coverImage: ((($0["snippet"] as! JSONObject)["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] as? String, sourcePlatform: .youTube)
//            })
//            if jsonData.keys.contains("nextPageToken") {
//                playlistReq = HTTPRequest(method: .get, url: URL(string: "https://youtube.googleapis.com/youtube/v3/playlists?part=snippet%2CcontentDetails&maxResults=50&mine=true&key=\(api_key!)&pageToken=\(jsonData["nextPageToken"] as! String)")!)
//                playlistReq!.headerFields[.authorization] = "Bearer \(keychain["yt_access_token"]!)"
//            }
//            else {
//                playlistReq = nil
//            }
//        } while playlistReq != nil
//        
//        return allPlaylists
//    }
//    
//    static func getPlaylistItems(playlistID: String) async throws -> [SongData] {
//        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
//        let api_key = Bundle.main.infoDictionary?["GOOGLE_CLIENT"] as? String
//        
//        var allSongs: [SongData] = []
//        
//        var videoReq: HTTPRequest? = HTTPRequest(method: .get, url: URL(string: "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=50&playlistId=\(playlistID)&key=\(api_key!)")!)
//        videoReq!.headerFields[.authorization] = "Bearer \(keychain["yt_access_token"]!)"
//        
//        repeat {
//            let (data, _) = try await URLSession.shared.data(for: videoReq!)
//            let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
//            
//            allSongs.append(contentsOf: (jsonData["items"] as! [JSONObject]).map {
//                
//                SongData(name: ($0["snippet"] as! JSONObject)["title"] as! String,
//                    artists: [(($0["snippet"] as! JSONObject)["videoOwnerChannelTitle"] as? String) ?? ""],
//                    albumName: "",
//                    albumArtists: [],
//                    isrc: "",
//                    amid: "",
//                    spid: "",
//                    ytid: $0["id"] as? String,
//                         coverImage: ((($0["snippet"] as! JSONObject)["thumbnails"] as! JSONObject)["default"] as? JSONObject) == nil ? "" : ((($0["snippet"] as! JSONObject)["thumbnails"] as! JSONObject)["default"] as! JSONObject)["url"] as? String)
//            })
//            if jsonData.keys.contains("nextPageToken") {
//                videoReq = HTTPRequest(method: .get, url: URL(string: "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=50&playlistId=\(playlistID)&key=\(api_key!)&pageToken=\(jsonData["nextPageToken"] as! String)")!)
//                videoReq!.headerFields[.authorization] = "Bearer \(keychain["yt_access_token"]!)"
//            }
//            else {
//                videoReq = nil
//            }
//        } while videoReq != nil
//        
//        
//        return allSongs
//    }
//}

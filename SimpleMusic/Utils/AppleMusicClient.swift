//
//  AppleMusicClient.swift
//  SimpleMusic
//
//  Created by John Graham on 8/11/23.
//

import Foundation
import MusicKit
import KeychainAccess


class AppleMusicClient {
    static func getSongMatches(playlist: PlaylistData) async throws -> [SongData] {
        let songs = try await SpotifyClient.getPlaylistSongs(playlistID: playlist.spid)
        let total = songs.count
        var matches = 0
        for song in songs {
            let musicURL = URLRequest(url: URL(string: "https://api.music.apple.com/v1/catalog/us/songs?filter[isrc]=\(song.isrc)")!)
            let musicReq = MusicDataRequest(urlRequest: musicURL)
            let jsonData = try await JSONSerialization.jsonObject(with: musicReq.response().data) as! JSONObject
            if !jsonData.contains(where: {$0.key == "data"}) {
                print("Nothing found for \(song.name), skipping...")
            }
            else {
                let songDataArray = (jsonData["data"] as! [JSONObject])
                if songDataArray.isEmpty {
                    print("Nothing found for \(song.name), skipping...")
                    song.matchState = .failed
                }
                else {
                    let songData = songDataArray[0]
                    print("Matched \((songData["attributes"] as! JSONObject)["name"] as! String) by \((songData["attributes"] as! JSONObject)["artistName"] as! String)")
                    song.amid = songData["id"] as! String
                    let amSongReq = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(song.amid))
                    let amSong = try await amSongReq.response()
                    song.coverImage = amSong.items[0].artwork?.url(width: 300, height: 300)!.absoluteString
                    matches += 1
                    song.matchState = .successful
                }
            }
        }
        print("Matched \(matches) / \(total) songs.")
        return songs
    }
    
    static func createNewPlaylist(name: String, description: String?) async throws -> String {
        let playlistData = [
            "attributes": [
                "name": name,
                "description": description
            ]
        ]
        var musicURL = URLRequest(url: URL(string: "https://api.music.apple.com/v1/me/library/playlists")!)
        musicURL.httpMethod = "POST"
        musicURL.httpBody = try JSONSerialization.data(withJSONObject: playlistData)
        let musicReq = MusicDataRequest(urlRequest: musicURL)
        let jsonData = try await JSONSerialization.jsonObject(with: musicReq.response().data) as! JSONObject
        return (jsonData["data"] as! [JSONObject])[0]["id"] as! String
    }
    
    static func addSongsToPlaylist(AMPlaylistID: String, songs: [SongData]) async throws {
        let reqSongData = ["data": songs.map({["id": $0.amid, "type": "songs"]})]
        var musicURL = URLRequest(url: URL(string: "https://api.music.apple.com/v1/me/library/playlists/\(AMPlaylistID)/tracks")!)
        musicURL.httpMethod = "POST"
        musicURL.httpBody = try JSONSerialization.data(withJSONObject: reqSongData)
        let musicReq = MusicDataRequest(urlRequest: musicURL)
        let jsonData = try await JSONSerialization.jsonObject(with: musicReq.response().data) as! JSONObject
        print(jsonData)
    }
    
    static func getPlaylists() async throws -> [PlaylistData] {
        var musicURL = URLRequest(url: URL(string: "https://api.music.apple.com/v1/me/library/playlists")!)
        musicURL.httpMethod = "GET"
        let musicReq = MusicDataRequest(urlRequest: musicURL)
        let jsonData = try await JSONSerialization.jsonObject(with: musicReq.response().data) as! JSONObject
        
        var allPlaylists: [PlaylistData] = []
        allPlaylists.append(contentsOf: (jsonData["data"] as! [JSONObject]).map {
            PlaylistData(name: ($0["attributes"] as! JSONObject)["name"] as! String, amid: $0["id"] as! String, spid: "", coverImage: "", sourcePlatform: .appleMusic)
        })
        return allPlaylists
    }
    
    static func getPlaylistSongs(playlistID: String) async throws -> [SongData] {
        var allSongs: [SongData] = []
        
        var musicURL = URLRequest(url: URL(string: "https://api.music.apple.com/v1/me/library/playlists/\(playlistID)/tracks")!)
        musicURL.httpMethod = "GET"
        let musicReq = MusicDataRequest(urlRequest: musicURL)
        let jsonData = try await JSONSerialization.jsonObject(with: musicReq.response().data) as! JSONObject
        
        let allIDs = (jsonData["data"] as! [JSONObject]).map {
            (($0["attributes"] as! JSONObject)["playParams"] as! JSONObject)["catalogId"] as! String
        }
        for id in allIDs {
            let resourceReq = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(id))
            let resourceResponse = try await resourceReq.response().items[0]
            allSongs.append(SongData(name: resourceResponse.title,
                                     artists: [resourceResponse.artistName],
                                     albumName: resourceResponse.albumTitle!,
                                     albumArtists: [resourceResponse.artistName],
                                     isrc: resourceResponse.isrc!,
                                     amid: resourceResponse.id.rawValue,
                                     spid: "",
                                     coverImage: resourceResponse.artwork!.url(width: 300, height: 300)!.absoluteString
            ))
        }
        return allSongs
    }
}

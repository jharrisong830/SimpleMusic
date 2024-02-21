//
//  AppleMusicClient.swift
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
import MusicKit


class AppleMusicClient {
    static func getSongMatches(playlist: PlaylistData) async throws -> [SongData] {
        let total = playlist.songs.count
        var matches = 0
        var newSongs: [SongData] = []
        for song in playlist.songs {
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
                    newSongs.append(SongData(name: song.name, artists: song.artists, albumName: song.albumName, albumArtists: song.albumArtists, isrc: song.isrc, platform: song.platform, platformID: song.platformID, platformURL: song.platformURL, coverImage: song.coverImage, playlist: nil, index: song.index, matchState: .failed))
                }
                else {
                    let songData = songDataArray[0]
                    let albumMatchID = parseAlbums(amDataResponse: songDataArray, originalSong: song)
                    let newID = albumMatchID ?? songData["id"] as! String
                    print("Matched \((songData["attributes"] as! JSONObject)["name"] as! String) by \((songData["attributes"] as! JSONObject)["artistName"] as! String)")
                    let amSongReq = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(newID))
                    let amSong = try await amSongReq.response()
                    matches += 1
                    newSongs.append(SongData(name: amSong.items[0].title,
                                             artists: song.artists,
                                             albumName: amSong.items[0].albumTitle ?? "",
                                             albumArtists: song.albumArtists,
                                             isrc: song.isrc,
                                             platform: .appleMusic,
                                             platformID: newID,
                                             platformURL: amSong.items[0].url,
                                             coverImage: amSong.items[0].artwork?.url(width: 300, height: 300),
                                             playlist: nil,
                                             index: song.index,
                                             matchState: .successful))
                }
            }
        }
        print("Matched \(matches) / \(total) songs.")
        return newSongs
    }
    
    
    
//    static func getSingleSongMatch(song: SongData) async throws -> SongData {
//        let musicURL = URLRequest(url: URL(string: "https://api.music.apple.com/v1/catalog/us/songs?filter[isrc]=\(song.isrc)")!)
//        let musicReq = MusicDataRequest(urlRequest: musicURL)
//        let jsonData = try await JSONSerialization.jsonObject(with: musicReq.response().data) as! JSONObject
//        if !jsonData.contains(where: {$0.key == "data"}) {
//            print("Nothing found for \(song.name), skipping...")
//        }
//        else {
//            let songDataArray = (jsonData["data"] as! [JSONObject])
//            if songDataArray.isEmpty {
//                print("Nothing found for \(song.name), skipping...")
//                song.matchState = .failed
//            }
//            else {
//                let songData = songDataArray[0]
//                let albumMatchID = parseAlbums(amDataResponse: songDataArray, originalSong: song)
//                song.platformID = albumMatchID ?? songData["id"] as! String
//                song.platform = .appleMusic
//                print("Matched \((songData["attributes"] as! JSONObject)["name"] as! String) by \((songData["attributes"] as! JSONObject)["artistName"] as! String)")
//                let amSongReq = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(song.platformID))
//                let amSong = try await amSongReq.response()
//                song.coverImage = amSong.items[0].artwork?.url(width: 300, height: 300)
//                song.platformURL = amSong.items[0].url
//                song.matchState = .successful
//            }
//        }
//        return song
//    }
    
    
    
    static func parseAlbums(amDataResponse: [JSONObject], originalSong: SongData) -> String? {
        for song in amDataResponse {
            let data = song["attributes"] as! JSONObject
            if data["albumName"] as! String == originalSong.albumName {
                return song["id"] as? String
            }
        }
        return nil
    }
    
    static func createNewPlaylist(name: String, description: String?) async throws -> String {
        let playlistData = [
            "attributes": [
                "name": name,
                "description": description ?? "transferred with <3 by SimpleMusic"
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
        let reqSongData = ["data": songs.map({["id": $0.platformID, "type": "songs"]})]
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
            PlaylistData(name: ($0["attributes"] as! JSONObject)["name"] as! String, 
                         platform: .appleMusic,
                         platformID: $0["id"] as! String,
                         platformURL: nil,
                         coverImage: nil)
        })
        return allPlaylists
    }
    
    static func getPlaylistSongs(playlist: PlaylistData) async throws -> [SongData] {
        var allSongs: [SongData] = []
        
        var musicURL = URLRequest(url: URL(string: "https://api.music.apple.com/v1/me/library/playlists/\(playlist.platformID)/tracks")!)
        musicURL.httpMethod = "GET"
        let musicReq = MusicDataRequest(urlRequest: musicURL)
        let jsonData = try await JSONSerialization.jsonObject(with: musicReq.response().data) as! JSONObject
        
        let allIDs = (jsonData["data"] as! [JSONObject]).map {
            let attr = $0["attributes"] as! JSONObject
            if attr.keys.contains("playParams") {
                return (attr["playParams"] as! JSONObject)["catalogId"] as! String
            }
            else {
                return ""
            }
            // (($0["attributes"] as! JSONObject)["playParams"] as! JSONObject)["catalogId"] as! String
        }
        for (ind, id) in allIDs.enumerated() {
            if id.isEmpty {
                allSongs.append(SongData.nilSong)
            }
            else {
                let resourceReq = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(id))
                let resourceResponse = try await resourceReq.response().items[0]
                allSongs.append(SongData(name: resourceResponse.title,
                                         artists: [resourceResponse.artistName],
                                         albumName: resourceResponse.albumTitle!,
                                         albumArtists: [resourceResponse.artistName],
                                         isrc: resourceResponse.isrc!,
                                         platform: .appleMusic,
                                         platformID: resourceResponse.id.rawValue,
                                         platformURL: resourceResponse.url,
                                         coverImage: resourceResponse.artwork!.url(width: 300, height: 300),
                                         playlist: nil,
                                         index: ind
                                        ))
            }
        }
        return allSongs
    }
}

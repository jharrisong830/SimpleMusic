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
    func createAppleMusicPlaylist(playlist: PlaylistData) async throws -> [SongData] {
        let songs = try await SpotifyClient().getPlaylistSongs(playlistID: playlist.spid)
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
                }
                else {
                    let songData = songDataArray[0]
                    print("Matched \((songData["attributes"] as! JSONObject)["name"] as! String) by \((songData["attributes"] as! JSONObject)["artistName"] as! String)")
                    song.amid = songData["id"] as! String
                    matches += 1
                }
            }
        }
        print("Matched \(matches) / \(total) songs.")
        return songs
        
        
    }
}

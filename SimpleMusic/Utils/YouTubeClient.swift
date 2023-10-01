//
//  YouTubeClient.swift
//  SimpleMusic
//
//  Created by John Graham on 9/20/23.
//

import Foundation
import KeychainAccess
import HTTPTypes
import HTTPTypesFoundation


class YouTubeClient {
    static private let redirect = "simple-music://"
    
    static func initialAuthAccess(authCode: String) async throws {
        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
        let api_key = Bundle.main.infoDictionary?["GOOGLE_CLIENT"] as? String
    
        var newRequest = HTTPRequest(method: .post, url: URL(string: "https://oauth2.googleapis.com/token")!)
        newRequest.headerFields[.contentType] = "application/x-www-form-urlencoded"
        let accessParams = "client_id=\(api_key!)&code=\(authCode)&grant_type=authorization_code&redirect_uri=com.googleusercontent.apps.246281019333-flnmf3geqs3h7lvequcisei2b647vktb:/simple-music&response_type=code&scope=https://www.googleapis.com/auth/youtube"
        
        let (data, _) = try await URLSession.shared.upload(for: newRequest, from: accessParams.data(using: .utf8)!)
        let jsonData = try JSONSerialization.jsonObject(with: data) as! JSONObject
        print(jsonData)
        
        // set codes in keychain
        try keychain.remove("sp_access_token")
        try keychain.remove("sp_refresh_token")
        try keychain.remove("sp_access_expiration")
        keychain["yt_access_token"] = jsonData["access_token"] as? String
        keychain["yt_refresh_token"] = jsonData["refresh_token"] as? String
        keychain["yt_access_expiration"] = ((jsonData["expires_in"] as! Double) + Date.now.timeIntervalSince1970).description
    }
}

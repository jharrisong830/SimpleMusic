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
    
//    static func initialAuthAccess() async throws {
//        let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
//        let api_key = Bundle.main.infoDictionary?["GOOGLE_CLIENT"] as? String
//        
//        var newRequest = HTTPRequest(method: .post, url: URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!)
//        let accessParams = "client_id=\(api_key)&redirect_uri=\(redirect)&response_type=code&scope=https://www.googleapis.com/auth/youtube"
//        
//    }
}

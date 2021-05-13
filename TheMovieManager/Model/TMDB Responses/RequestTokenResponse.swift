//
//  RequestTokenResponse.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import Foundation

struct RequestTokenResponse: Codable {
    
    var success: Bool
    var expiresAt: String
    var requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
    
}



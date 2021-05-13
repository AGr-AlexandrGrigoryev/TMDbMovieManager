//
//  PostSession.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import Foundation


struct PostSession: Codable {
    /// Use for POST Request Body to get sessionID
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
}

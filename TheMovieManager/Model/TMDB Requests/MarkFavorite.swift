//
//  MarkFavorite.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import Foundation

/// Request Body,  application/json
struct MarkFavorite: Codable {
    
    let mediaType: String
    let mediaId: Int
    let favorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case favorite
    }
}


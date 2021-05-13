//
//  MarkWatchlist.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import Foundation

/// Request Body,  application/json
struct MarkWatchlist: Codable {
    let mediaType: String
    let mediaId: Int
    let watchList: Bool
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case watchList = "watchlist"
    }
}

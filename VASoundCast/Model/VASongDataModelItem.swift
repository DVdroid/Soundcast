//
//  VASongItem.swift
//  VASoundCast
//
//  Created by Vikash Anand on 09/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import Foundation

struct VASongDataModelItem {
    
    private static let songIdentifier = "id"
    private static let songTitle = "title"
    private static let songUrl = "link"
    private static let songThumbNailUrl = "thumbnail"
    //private static let thumbNail = "thumbnail"
    private static let cachedSongUrl = "cachedSongUrl"
    
    let id: Int?
    let title: String?
    let url: String?
    let thumbnailUrl: String?
    let cachedSongUrl: URL?
    
    init?(withData data: [String: Any]) {
        
        let typeSelf = type(of: self)
        guard let id = data[typeSelf.songIdentifier],
            let title = data[typeSelf.songTitle],
            let url = data[typeSelf.songUrl],
            let thumbnailUrl = data[typeSelf.songThumbNailUrl],
            let cachedSongUrl = data[typeSelf.cachedSongUrl] else { return nil }
        
        self.id = id as? Int
        self.title = title as? String
        self.url = url as? String
        self.thumbnailUrl = thumbnailUrl as? String
        self.cachedSongUrl = cachedSongUrl as? URL
    }
}

extension VASongDataModelItem: Equatable {
    
    static func ==(lhs: VASongDataModelItem, rhs: VASongDataModelItem) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.url == rhs.url &&
            lhs.thumbnailUrl == rhs.thumbnailUrl &&
            lhs.cachedSongUrl == rhs.cachedSongUrl
    }
}

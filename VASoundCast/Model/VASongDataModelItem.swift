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
    private static let cachedSongUrl = "cachedSongUrl"
    
    let id: Int?
    let title: String?
    let url: String?
    let thumbnailUrl: String?
    let cachedSongUrl: URL?
    
    init(withData data: [String: Any]) {
        
        let typeSelf = type(of: self)
        self.id = data[typeSelf.songIdentifier] as? Int
        self.title = data[typeSelf.songTitle] as? String
        self.url = data[typeSelf.songUrl] as? String
        self.thumbnailUrl = data[typeSelf.songThumbNailUrl] as? String
        self.cachedSongUrl = data[typeSelf.cachedSongUrl] as? URL
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

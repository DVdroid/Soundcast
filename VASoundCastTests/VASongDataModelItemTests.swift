//
//  VASongDataModelItemTests.swift
//  VASoundCastTests
//
//  Created by Vikash Anand on 15/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import XCTest
@testable import VASoundCast

class VASongDataModelItemTests: XCTestCase {
    
    var songDataModelItem: VASongDataModelItem!
    
    override func setUp() {
        
        guard let cacheSongUrl = URL(string: "https://static.talview.com/hiring/android/soundcast/mp3/fast-and-furious.mp3") else { return }
        let response: [String : Any] = [
            "id": 1,
            "title": "Fast And Furious",
            "link": "https://static.talview.com/hiring/android/soundcast/mp3/fast-and-furious.mp3",
            "thumbnail": "https://static.talview.com/hiring/android/soundcast/thumbs/fast-and-furious.jpg",
            "cachedSongUrl": cacheSongUrl]
        self.songDataModelItem = VASongDataModelItem.init(withData: response)
    }

    override func tearDown() {
        self.songDataModelItem = nil
    }

    func testSongModelItem() {
        
        XCTAssertEqual(self.songDataModelItem.id, 1)
        XCTAssertEqual(self.songDataModelItem.title, "Fast And Furious")
        XCTAssertEqual(self.songDataModelItem.url, "https://static.talview.com/hiring/android/soundcast/mp3/fast-and-furious.mp3")
        XCTAssertEqual(self.songDataModelItem.thumbnailUrl, "https://static.talview.com/hiring/android/soundcast/thumbs/fast-and-furious.jpg")
        guard let cacheSongUrl = URL(string: "https://static.talview.com/hiring/android/soundcast/mp3/fast-and-furious.mp3") else { return }
        XCTAssertEqual(self.songDataModelItem.cachedSongUrl, cacheSongUrl)
    }
}

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
    
    override func setUp() {
    }

    override func tearDown() {
    }

    func testSongModelItem() {
        
        let songUrlString = "https://static/furious.mp3"
        guard let cacheSongUrl = URL(string: songUrlString) else { return }
        let response: [String : Any] = [
            "id": 1,
            "title": "Fast And Furious",
            "link": songUrlString,
            "thumbnail": "https://static/furious.jpg",
            "cachedSongUrl": cacheSongUrl]
        
        let songDataModelItem = VASongDataModelItem.init(withData: response)
        XCTAssertEqual(songDataModelItem.id, 1)
        XCTAssertEqual(songDataModelItem.title, "Fast And Furious")
        XCTAssertEqual(songDataModelItem.url, songUrlString)
        XCTAssertEqual(songDataModelItem.thumbnailUrl, "https://static/furious.jpg")
        XCTAssertEqual(songDataModelItem.cachedSongUrl, cacheSongUrl)
    }
    
    func testSongModelItemForEmptyData() {
        
        let responseData: [String : Any] = [:]
        let songDataModelItem = VASongDataModelItem.init(withData: responseData)
        XCTAssertNil(songDataModelItem.id)
        XCTAssertNil(songDataModelItem.title)
        XCTAssertNil(songDataModelItem.url)
        XCTAssertNil(songDataModelItem.thumbnailUrl)
        XCTAssertNil(songDataModelItem.cachedSongUrl)
    }
    
    func testEqualAllProperties() {
        
        let songUrlString = "https://static/furious.mp3"
        guard let cacheSongUrl = URL(string: songUrlString) else { return }
        
        let responseData1: [String : Any] = [
            "id": 1,
            "title": "Fast And Furious",
            "link": songUrlString,
            "thumbnail": "https://static/furious.jpg",
            "cachedSongUrl": cacheSongUrl]
        let songDataItem1 = VASongDataModelItem(withData: responseData1)
        
        let responseData2: [String : Any] = [
            "id": 1,
            "title": "Fast And Furious",
            "link": songUrlString,
            "thumbnail": "https://static/furious.jpg",
            "cachedSongUrl": cacheSongUrl]
        let songDataItem2 = VASongDataModelItem(withData: responseData2)
        
        XCTAssertEqual(songDataItem1, songDataItem2)
        XCTAssertEqual(songDataItem2, songDataItem1)
    }
    
    func testEqual_IdDiffers_isFalse() {
        
        let responseData1: [String : Any] = ["id": 1]
        let songDataItem1 = VASongDataModelItem(withData: responseData1)
        
        let responseData2: [String : Any] = ["id": 2]
        let songDataItem2 = VASongDataModelItem(withData: responseData2)
        
        XCTAssertNotEqual(songDataItem1, songDataItem2)
        XCTAssertNotEqual(songDataItem2, songDataItem1)
    }
    
    func testEqual_TitleDiffers_isFalse() {
        
        let responseData1: [String : Any] = ["title": "ABC"]
        let songDataItem1 = VASongDataModelItem(withData: responseData1)
        
        let responseData2: [String : Any] = ["title": ""]
        let songDataItem2 = VASongDataModelItem(withData: responseData2)
        
        XCTAssertNotEqual(songDataItem1, songDataItem2)
        XCTAssertNotEqual(songDataItem2, songDataItem1)
    }
    
    func testEqual_SongUrlDiffers_isFalse() {
        
        let responseData1: [String : Any] = ["link": "https://furious.mp3"]
        let songDataItem1 = VASongDataModelItem(withData: responseData1)
        
        let responseData2: [String : Any] = ["link": ""]
        let songDataItem2 = VASongDataModelItem(withData: responseData2)
        
        XCTAssertNotEqual(songDataItem1, songDataItem2)
        XCTAssertNotEqual(songDataItem2, songDataItem1)
    }
    
    func testEqual_thumbnailUrlDiffers_isFalse() {
        
        let responseData1: [String : Any] = ["thumbnail": "https://furious.jpg"]
        let songDataItem1 = VASongDataModelItem(withData: responseData1)
        
        let responseData2: [String : Any] = ["thumbnail": ""]
        let songDataItem2 = VASongDataModelItem(withData: responseData2)
        
        XCTAssertNotEqual(songDataItem1, songDataItem2)
        XCTAssertNotEqual(songDataItem2, songDataItem1)
    }
    
    func testEqual_songUrlDiffers_isFalse() {
        
        let songUrlString1 = "https://static/furious.mp3"
        guard let cacheSongUrl1 = URL(string: songUrlString1) else { return }
        let songUrlString2 = ""
        guard let cacheSongUrl2 = URL(string: songUrlString2) else { return }
        
        let responseData1: [String : Any] = ["cachedSongUrl": cacheSongUrl1]
        let songDataItem1 = VASongDataModelItem(withData: responseData1)
        
        let responseData2: [String : Any] = ["cachedSongUrl": cacheSongUrl2]
        let songDataItem2 = VASongDataModelItem(withData: responseData2)
        
        XCTAssertNotEqual(songDataItem1, songDataItem2)
        XCTAssertNotEqual(songDataItem2, songDataItem1)
    }
}

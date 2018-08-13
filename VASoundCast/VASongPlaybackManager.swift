//
//  VASongPlaybackManager.swift
//  VASoundCast
//
//  Created by Vikash Anand on 13/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import AVKit

final class VASongPlaybackManager: NSObject {
    
    static let sharedInstance: VASongPlaybackManager = {
        let sharedInstance = VASongPlaybackManager()
        sharedInstance.enableBackgroundPlayBack()
        
        return sharedInstance
    }()
    
    private override init() {}
    private lazy var player: VASongPlayer = {
        let player = VASongPlayer(withPlaybackDelegate: self)
        return player
        
    }()
    
    private var currentSongIndex: Int = 0
    var playBackCompletionHandler:((Error?)->())?
    var playbackProgressTrackingnHandler:((String, String)->())?
    
    var songsList: [VASongDataModelItem]?
    var thumbnailCache: NSCache<NSString, UIImage>?
    private func enableBackgroundPlayBack() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(error)
        }
    }
    
    func startPlayBack(forSongAtIndex index: Int) {
        self.currentSongIndex = index
        guard let songlist = self.songsList, let songUrl = songlist[index].cachedSongUrl else { return }
        self.player.setupPlayer(withUrl: songUrl)
    }
    
    func startPlayBack() {
        self.startPlayBack(forSongAtIndex: self.currentSongIndex)
    }
    
    func play() {
        if !self.player.isPlaying {
            self.player.play()
        }
    }
    
    func pause() {
        if self.player.isPlaying {
            self.player.pause()
        }
    }

    func stop() {
        self.player.stop()
        if let playBackCompletionHandler = self.playBackCompletionHandler {
            playBackCompletionHandler(nil)
        }
    }
    
    func getTrackInfo(forIndex index: Int, withCompletionHandler handler:(String,UIImage)->()) {
        self.currentSongIndex = index
        guard let songsList = self.songsList, let songTitle = songsList[self.currentSongIndex].title,
            let cachedImageUrlAsString = songsList[self.currentSongIndex].thumbnailUrl as NSString?  else { return }
        guard let cache = self.thumbnailCache, let cachedImage = cache.object(forKey: cachedImageUrlAsString) as UIImage? else { return }
        
        handler(songTitle, cachedImage)
    }
    
    func nextTrack(withCompletionHandler handler:(String,UIImage)->()) {
        self.stop()
        self.currentSongIndex = self.currentSongIndex + 1
        if let count = self.songsList?.count, self.currentSongIndex <= (count - 1) {
            guard let songsList = self.songsList, let songTitle = songsList[self.currentSongIndex].title,
                let cachedImageUrlAsString = songsList[self.currentSongIndex].thumbnailUrl as NSString?  else { return }
            guard let cache = self.thumbnailCache, let cachedImage = cache.object(forKey: cachedImageUrlAsString) as UIImage? else { return }
            handler(songTitle, cachedImage)
            
            self.startPlayBack(forSongAtIndex: self.currentSongIndex)
        } else {
            
            if let count = self.songsList?.count {
                self.currentSongIndex = count - 1
            }
        }
    }
    
    func previousTrack(withCompletionHandler handler:(String, UIImage)->()) {
        self.stop()
        self.currentSongIndex = self.currentSongIndex - 1
        if self.currentSongIndex >= 0 {
            guard let songsList = self.songsList, let songTitle = songsList[self.currentSongIndex].title,
                let cachedImageUrlAsString = songsList[self.currentSongIndex].thumbnailUrl as NSString?  else { return }
            guard let cache = self.thumbnailCache, let cachedImage = cache.object(forKey: cachedImageUrlAsString) as UIImage? else { return }
            handler(songTitle, cachedImage)
            
            self.startPlayBack(forSongAtIndex: self.currentSongIndex)
        } else {
            self.currentSongIndex = 0
        }
    }
}

extension VASongPlaybackManager: VASongPlayerDelegate {
    
    func didFinishPlayBack(_ player: AVAudioPlayer, withError: Error?) {
        if let playBackCompletionHandler = self.playBackCompletionHandler {
            playBackCompletionHandler(withError)
        }
    }
    
    func playBackInProgress(withCurrentDuration durationDone: String,
                            totalDurationleft durationLeft: String) {
        if let playbackProgressTrackingnHandler = self.playbackProgressTrackingnHandler {
            playbackProgressTrackingnHandler(durationDone, durationLeft)
        }
    }
}

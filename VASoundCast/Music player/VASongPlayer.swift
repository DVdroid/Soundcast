//
//  VASongPlayer.swift
//  VASoundCast
//
//  Created by Vikash Anand on 12/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import AVFoundation

protocol VASongPlayerDelegate: class {
    
    func didFinishPlayBack(_ player: AVAudioPlayer, withError: Error?)
    func playBackInProgress(forPlayer player: AVAudioPlayer)
}

class VASongPlayer: NSObject {
    
    required init(withPlaybackDelegate delegate: VASongPlayerDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    private var player: AVAudioPlayer?
    private var progessTrackingTimer: Timer?
    private weak var delegate: VASongPlayerDelegate?
    var isPlaying: Bool {
        return self.player?.isPlaying ?? false
    }
    
    func setupPlayer(withUrl url: URL, withCompletionHandler handler:(Bool)->()) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: "mp3")
            self.player?.delegate = self
            self.player?.prepareToPlay()
            self.play()
            handler(true)
        } catch {
            handler(false)
            print(error)
        }
    }
    
    func play() {
        self.player?.play()
        self.startProgressTrackingTimer()
    }
    
    func pause() {
        self.player?.pause()
    }
    
    func stop() {
        self.player?.stop()
        self.stopProgressTrackingTimer()
        self.player = nil
    }
    
    private func startProgressTrackingTimer() {
        self.updateAudioProgressView()
        self.progessTrackingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
    }
    
    @objc func updateAudioProgressView() {
        if self.isPlaying, let player = self.player {
            self.delegate?.playBackInProgress(forPlayer: player)
        }
    }
    
    private func stopProgressTrackingTimer() {
        self.progessTrackingTimer?.invalidate()
        self.progessTrackingTimer = nil
    }
}

extension VASongPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.delegate?.didFinishPlayBack(player, withError: error)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.didFinishPlayBack(player, withError: nil)
    }
}

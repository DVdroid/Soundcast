//
//  VASongPlayerViewController.swift
//  VASoundCast
//
//  Created by Vikash Anand on 12/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import UIKit
import AVKit

class VASongPlayerViewController: UIViewController {
    
    static let storyBoardName = "Main"
    static let nibName = "VASongPlayerViewController"
    static let identifier = "SongPlayer"
    static let pauseImageName = "pause_new"
    static let playImageName = "play_new"
    
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var songTitleLabel: UILabel!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var playPauseSongButton: VAMusicControlButton!
    @IBOutlet private var previousSongButton: VAMusicControlButton!
    @IBOutlet private var nextSongButton: VAMusicControlButton!
    @IBOutlet private var dismissButton: UIBarButtonItem!
    @IBOutlet private var currentDurationLabel: UILabel!
    @IBOutlet private var totalDurationLabel: UILabel!
    @IBOutlet private var navigationBar: UINavigationBar!
    private var songIndex: Int?
    private lazy var audioPlayerManager = VASongPlaybackManager.sharedInstance
    
    class func loadVC(withSongIndex index: Int) -> VASongPlayerViewController? {
        let storyBoard = UIStoryboard(name: VASongPlayerViewController.storyBoardName, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: VASongPlayerViewController.identifier) as? VASongPlayerViewController else { return nil }
        viewController.songIndex = index
        
        return viewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureNavigationBar()
        let selfType = type(of: self)
        self.configurePlayerManager()
        self.configureButtonAction()
        self.playPauseSongButton.imageName = selfType.pauseImageName
    }
    
    private func configurePlayerManager() {
        
        guard let songIndex = self.songIndex else { return }
        self.audioPlayerManager.playBackCompletionHandler = { error in
            let selfType = type(of: self)
            self.playPauseSongButton.imageName = selfType.playImageName
        }
    
        self.audioPlayerManager.playBackCompletionHandler = { error in
            let selfType = type(of: self)
            self.playPauseSongButton.imageName = selfType.playImageName
            self.currentDurationLabel.text = self.totalDurationLabel.text
            self.progressView.setProgress(1.0, animated: true)
        }
        
        self.audioPlayerManager.playbackProgressTrackingnHandler = { trackingProgress in
            self.progressView.setProgress(trackingProgress, animated: true)
        }
        
        self.audioPlayerManager.playbackTimeHandler = {  durationDone , totalDuration in
            self.currentDurationLabel.text = durationDone
            self.totalDurationLabel.text = totalDuration
        }
        
        self.audioPlayerManager.getTrackInfo(forIndex: songIndex) { [weak self](songTitle, thumbnailImage) in
            guard let strongSelf = self else { return }
            strongSelf.thumbnailImageView.image = thumbnailImage
            strongSelf.songTitleLabel.text = songTitle
            strongSelf.applyCustomBackgroundColor()
        }
        
        if self.audioPlayerManager.isPlaying {
            self.audioPlayerManager.stop()
        }
        self.audioPlayerManager.startPlayBack(forSongAtIndex: songIndex)
    }
    
    private func applyCustomBackgroundColor() {
        self.view.backgroundColor = self.thumbnailImageView.image?.averageColor
    }
    
    private func configureNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
    }
    
    private func configureButtonAction() {
        
        self.playPauseSongButton.buttonActionHandler = {
            
            let selfType = type(of: self)
            if !self.audioPlayerManager.isPlaying {
                self.audioPlayerManager.startPlayBack()
                self.playPauseSongButton.imageName = selfType.pauseImageName
            } else {
                self.audioPlayerManager.pause()
                self.playPauseSongButton.imageName = selfType.playImageName
            }
        }
        
        self.previousSongButton.buttonActionHandler = {
            self.audioPlayerManager.previousTrack(withCompletionHandler: { songTitle, thumnailImage in
                let selfType = type(of: self)
                self.songTitleLabel.text = songTitle
                self.thumbnailImageView.image = thumnailImage
                self.playPauseSongButton.imageName = selfType.pauseImageName
            })
        }
        
        self.nextSongButton.buttonActionHandler = {
            self.audioPlayerManager.nextTrack(withCompletionHandler: { songTitle, thumnailImage in
                let selfType = type(of: self)
                self.songTitleLabel.text = songTitle
                self.thumbnailImageView.image = thumnailImage
                self.playPauseSongButton.imageName = selfType.pauseImageName
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissPlayerController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.audioPlayerManager.stop()
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [kCIContextWorkingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

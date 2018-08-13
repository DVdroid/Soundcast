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
    private var isPlaying: Bool = false
    
    class func loadVC(withSongIndex index: Int) -> VASongPlayerViewController? {
        let storyBoard = UIStoryboard(name: VASongPlayerViewController.storyBoardName, bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: VASongPlayerViewController.identifier) as? VASongPlayerViewController else { return nil }
        viewController.songIndex = index
        
        return viewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let songIndex = self.songIndex else { return }
        self.playPauseSongButton.imageName = "pause_new"
        self.isPlaying = !self.isPlaying
        self.audioPlayerManager.playBackCompletionHandler = { error in
            self.playPauseSongButton.imageName = "play_new"
            self.isPlaying = !self.isPlaying
        }
        self.audioPlayerManager.startPlayBack(forSongAtIndex: songIndex)
        
        self.audioPlayerManager.playbackProgressTrackingnHandler = { durationDone , durationLeft in
            self.currentDurationLabel.text = durationDone
            self.totalDurationLabel.text = durationLeft
            if let durationDoneFloat = Float(durationDone), let durationLeftFloat = Float(durationLeft) {
                self.progressView.setProgress((durationDoneFloat / durationLeftFloat), animated: true)
            }
        }
        
        self.configureNavigationBar()
        self.configureButtonAction()
        
        guard let index = self.songIndex else { return }
        self.audioPlayerManager.getTrackInfo(forIndex: index) { [weak self](songTitle, thumbnailImage) in
            
            guard let strongSelf = self else { return }
            strongSelf.thumbnailImageView.image = thumbnailImage
            strongSelf.songTitleLabel.text = songTitle
            strongSelf.applyCustomBackgroundColor()
        }
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
            
            if !self.isPlaying {
                self.audioPlayerManager.startPlayBack()
                self.playPauseSongButton.imageName = "pause_new"
            } else {
                self.audioPlayerManager.pause()
                self.playPauseSongButton.imageName = "play_new"
            }
            self.isPlaying = !self.isPlaying
        }
        
        self.previousSongButton.buttonActionHandler = {
            self.audioPlayerManager.previousTrack(withCompletionHandler: { songTitle, thumnailImage in
                self.isPlaying = !self.isPlaying
                self.songTitleLabel.text = songTitle
                self.thumbnailImageView.image = thumnailImage
                self.playPauseSongButton.imageName = "pause_new"
            })
        }
        
        self.nextSongButton.buttonActionHandler = {
            self.audioPlayerManager.nextTrack(withCompletionHandler: { songTitle, thumnailImage in
                self.isPlaying = !self.isPlaying
                self.songTitleLabel.text = songTitle
                self.thumbnailImageView.image = thumnailImage
                self.playPauseSongButton.imageName = "pause_new"
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
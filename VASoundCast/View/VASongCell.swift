//
//  VASongCell.swift
//  VASoundCast
//
//  Created by Vikash Anand on 09/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import UIKit

class VASongCell: UITableViewCell {

    static let nibName = "VASongCell"
    static let identifier = "songCell"
    static let playImageName = "play_new"
    
    var playPauseClickHandler:(()->())?
    @IBOutlet private var songThumbNailImageView: UIImageView!
    @IBOutlet private var songTitleLabel: UILabel!
    @IBOutlet private var playPauseSongButton: VAMusicControlButton!
    
    func setup() {
        let selfType = type(of: self)
        self.playPauseSongButton.imageName = selfType.playImageName
        self.playPauseSongButton.buttonActionHandler = {
            if let playPauseClickHandler = self.playPauseClickHandler {
                playPauseClickHandler()
            }
        }
    }
    
    func updateSongTitle(withText songTitle:String) {
        self.songTitleLabel.text = songTitle
    }
    
    func updatePlayPauseButton(withImageName imageName: String) {
        self.playPauseSongButton.imageName = imageName
    }
    
    func updateSongThumNail(withImage image:UIImage) {
        self.songThumbNailImageView.image = image
    }
}

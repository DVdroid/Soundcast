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
    
    @IBOutlet private var songThumbNailImageView: UIImageView!
    @IBOutlet private var songTitleLabel: UILabel!
    
    func updateSongTitle(withText songTitle:String) {
        self.songTitleLabel.text = songTitle
    }
    
    func updateSongThumNail(withImage image:UIImage) {
        self.songThumbNailImageView.image = image
    }
}

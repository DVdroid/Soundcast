//
//  VAMusicControlButton.swift
//  VASoundCast
//
//  Created by Vikash Anand on 12/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import UIKit

class VAMusicControlButton: UIView {
    
    var buttonActionHandler:(()->())?
    private lazy var button: UIButton = {
        let button = UIButton(frame: self.bounds)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    @IBInspectable var imageName: String? {
        didSet {
           self.imageView.image  = UIImage(named: self.imageName ?? "")
        }
    }
    
    @IBInspectable var isBorderRequired: Bool = true {
        didSet {
            
            if !self.isBorderRequired {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        
        self.addSubview(self.button)
        NSLayoutConstraint.activate([
            self.button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.button.topAnchor.constraint(equalTo: self.topAnchor),
            self.trailingAnchor.constraint(equalTo: self.button.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: self.button.bottomAnchor)
            ])
        
        self.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
            self.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 7.0),
            self.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 10.0)
            ])
        
        self.layer.cornerRadius = self.frame.size.width / 2
        if self.isBorderRequired {
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 2.0
        }
    }
    
    @objc private func buttonAction() {
        if let buttonActionHandler = self.buttonActionHandler {
            buttonActionHandler()
        }
    }
}

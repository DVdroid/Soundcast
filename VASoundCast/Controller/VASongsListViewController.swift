//
//  VASongsListViewController.swift
//  VASoundCast
//
//  Created by Vikash Anand on 09/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import UIKit

class VASongsListViewController: UIViewController {

    static let pauseImageName = "pause_new"
    static let playImageName = "play_new"
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    @IBOutlet private var songsTableView: UITableView! {
        didSet {
            self.songsTableView.dataSource = self
            self.songsTableView.delegate = self
            self.songsTableView.estimatedRowHeight = 200
            self.songsTableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    private lazy var dataSource: VADataFetcher = {
        let dataFetcher = VADataFetcher(withDelegate: self)
        return dataFetcher
    }()
    
    private var dataArray = [VASongDataModelItem]() {
        didSet {
            self.songsTableView.reloadData()
        }
    }
    
    private lazy var audioPlayerManager = VASongPlaybackManager.sharedInstance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.songsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Songs"
        self.dataSource.requestData()
        self.showActivityIndicator()
    }
    
    private func showActivityIndicator() {
        self.view.addSubview(self.activityIndicator)
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        self.activityIndicator.startAnimating()
    }
    
    private func removeActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
}

extension VASongsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selfType = type(of: self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VASongCell.identifier) as? VASongCell else { return VASongCell() }
        cell.selectionStyle = .none
        cell.setup()
        cell.playPauseClickHandler = {
            if !self.audioPlayerManager.isPlaying {
                self.audioPlayerManager.startPlayBack(forSongAtIndex: indexPath.row)
                cell.updatePlayPauseButton(withImageName: selfType.pauseImageName)
            } else {
                cell.updatePlayPauseButton(withImageName: selfType.playImageName)
                self.audioPlayerManager.stop()
            }
            
            self.audioPlayerManager.playBackCompletionHandler = { error in
                cell.updatePlayPauseButton(withImageName: selfType.playImageName)
            }
        }
        
        let songDataItem = self.dataArray[indexPath.row]
        
        guard let title = songDataItem.title else { return VASongCell() }
        cell.updateSongTitle(withText: title)
        guard let thumbNailImageUrl = songDataItem.thumbnailUrl as NSString? else { return VASongCell() }
        self.dataSource.getThumbnail(forUrl: thumbNailImageUrl as String, withCompletionHandler: { image in
            if let cellToUpdate = self.songsTableView.cellForRow(at: indexPath) as? VASongCell {
                cellToUpdate.updateSongThumNail(withImage: image)
            } else {
                cell.updateSongThumNail(withImage: image)
            }
        })
        
        return cell
    }
}

extension VASongsListViewController: VAVADataFetcherDelegate {
    
    func didFail(withError error: VADataFetcherError) {
        print("Error is = \(String(describing: error.errorDescription))")
        self.removeActivityIndicator()
    }
    
    func didReceive(response responseData: [VASongDataModelItem], andThumnailCache cache: NSCache<NSString, UIImage>) {
        self.dataArray = responseData
        self.audioPlayerManager.songsList = responseData
        self.audioPlayerManager.thumbnailCache = cache
        self.removeActivityIndicator()
    }
}

extension VASongsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let songPlayVC = VASongPlayerViewController.loadVC(withSongIndex: indexPath.row) else { return }
            self.present(songPlayVC, animated: true, completion: nil)
        }
    }
}


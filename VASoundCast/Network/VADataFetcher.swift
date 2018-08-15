//
//  VASongDataModel.swift
//  VASoundCast
//
//  Created by Vikash Anand on 11/08/18.
//  Copyright © 2018 Vikash Anand. All rights reserved.
//

import Alamofire

struct VADataFetcherError {
    let errorDescription: String?
    init(withDescription description: String) {
        self.errorDescription = description
    }
}

protocol VAVADataFetcherDelegate: class {
    func didReceive(response responseData: [VASongDataModelItem], andThumnailCache cache: NSCache<NSString, UIImage>)
    func didFail(withError error: VADataFetcherError)
}

class VADataFetcher {
    
    required init(withDelegate delegate: VAVADataFetcherDelegate) {
        self.delegate = delegate
        self.registerForAppEnterForegroundNotification()
    }
    
    private let imageCache = NSCache<NSString, UIImage>()
    private static let songsListURL = "https://www.jasonbase.com/things/zKWW.json"
    weak var delegate: VAVADataFetcherDelegate?
    private var songsList = [VASongDataModelItem]()
    private func registerForAppEnterForegroundNotification() {
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification in
            self.recalculateCachedData()
        }
    }
    
    /*This methos is required as NSCache removes all the cached data when application enters background.
     So this method caches the resources again after application comes to the foreground.
     */
    private func recalculateCachedData() {
        for songDataItem in self.songsList {
            
            if let thumbNailImageUrl = songDataItem.thumbnailUrl as NSString? {
                self.getThumbnail(forUrl: thumbNailImageUrl as String, withCompletionHandler: { image in
                    if let thumbnailImage = image {
                         self.imageCache.setObject(thumbnailImage, forKey: thumbNailImageUrl)
                    }
                })
            }
        }
    }
    
    func requestData() {
        let typeSelf = type(of: self)
        Alamofire.request(typeSelf.songsListURL).validate().responseJSON { [weak self] response in
                            
            guard let strongSelf = self else { return }
            guard response.result.isSuccess, let dictionary = response.result.value as? [String: Any] else {
                
                if response.result.isFailure {
                    self?.delegate?.didFail(withError: VADataFetcherError(withDescription:response.error.debugDescription))
                }
                if response.data == nil {
                    self?.delegate?.didFail(withError: VADataFetcherError(withDescription:"No data received"))
                }
                return
            }
            
            guard let response = dictionary["songs"] as? [[String: Any]] else { return }
            strongSelf.setupModel(with: response)
        }
    }
    
    private func setupModel(with response: [[String: Any]]) {
        
         for (index,var songsInfo) in response.enumerated() {
            
            if let thumbNailImageUrl = songsInfo["thumbnail"] as? String {
                self.getThumbnail(forUrl: thumbNailImageUrl as String, withCompletionHandler: { _ in
                })
            }
            
            if let songUrl = songsInfo["link"] as? String {
                self.downloadSong(forUrl: songUrl) { destinationUrl in
                    
                    if let url = destinationUrl {
                        songsInfo["cachedSongUrl"] = url
                    }
                    
                    let songsDataModelItem = VASongDataModelItem(withData: songsInfo)
                    self.songsList.append(songsDataModelItem)
                    
                    if index == (self.songsList.count - 1) {
                        self.delegate?.didReceive(response: self.songsList, andThumnailCache: self.imageCache)
                    }
                }
            }
        }
    }
    
    private func downloadSong(forUrl urlString: String, withCompletionHandler handler: @escaping(URL?)->()) {
        guard let url = URL(string: urlString) else {
            handler(nil)
            return
        }
        self.storeFile(wthUrl: url, withCompletionHandler: handler)
    }
    
    private func storeFile(wthUrl fileUrl: URL, withCompletionHandler handler: @escaping(URL?)->()) {
        guard let documentDirectoryPath = self.documentDirectoryUrl() else {
            handler(nil)
            return
        }
        
        let destinationPathUrl = documentDirectoryPath.appendingPathComponent(fileUrl.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationPathUrl.path) {
            handler(destinationPathUrl)
        } else {
            
            Alamofire.download(fileUrl, to: { (_,_) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                return (destinationPathUrl, [.removePreviousFile])
            }).responseData { responseData in
                
                guard let destinationPathAsString = responseData.destinationURL else {
                    handler(nil)
                    return
                }
                do {
                    try FileManager.default.moveItem(at: destinationPathAsString, to: destinationPathUrl)
                    handler(destinationPathUrl)
                } catch {
                    handler(nil)
                    print(error)
                }
            }
        }
    }
    
    private func documentDirectoryUrl() -> URL? {
        guard let documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentDirectoryPath
    }
    
    func getThumbnail(forUrl urlString: String, withCompletionHandler handler:@escaping (UIImage?)->()) {
        
        guard let urlKey = urlString as NSString? else {
            handler(nil)
            return
        }
        if let cachedImage = self.imageCache.object(forKey: urlKey) {
            handler(cachedImage)
        } else {
            
            Alamofire.request(urlString).response{ response in
                guard let imageData = response.data, let image = UIImage(data: imageData) else {
                    handler(nil)
                    return
                }
                self.imageCache.setObject(image, forKey: urlKey)
                handler(image)
            }
        }
    }
}


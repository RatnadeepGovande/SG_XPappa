//
//  UploadStoreView.swift
//  App411
//
//  Created by osvinuser on 8/18/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import AVFoundation

class StoreInfoMode: NSObject {

    var isShowImage: Bool!
    var image: UIImage?
    var videoURL: URL?
    
    init(isShowImage: Bool, image: UIImage?, videoURL: URL?) {
        self.isShowImage = isShowImage
        self.image       = image
        self.videoURL    = videoURL
    }
    
}


protocol UploadStoreViewDelegate {
    func uploadVideoAndImage(isShowImage: Bool, image: UIImage?, videoURL: URL?, view: UIView)
}



class UploadStoreView: UIView {

    
    @IBOutlet var imageView_Image: UIImageView!
    @IBOutlet var crossButton: DesignableButton!
    @IBOutlet var sendStore: DesignableButton!
    @IBOutlet var playButton: UIButton!

    
    var imageView: UIImage!
    var videoURL: URL!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var storeInfoObj: StoreInfoMode? {
    
        didSet {
        
            if storeInfoObj?.isShowImage == true {
                
                if let showImage = storeInfoObj?.image {
                    imageView_Image.image = showImage
                    self.playerLayer?.removeFromSuperlayer()
                    self.playButton.isHidden = true
                }
                
            } else {
                
                if let videoURL = storeInfoObj?.videoURL {
                    player?.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                    player?.play()
                    self.playButton.isHidden = true

                }
                
            }
            
        }
        
    }
    
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            player?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }

    
    var delegate: UploadStoreViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "UploadStoreView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        
        // Add Video Layer.
        self.videoPlayLayer(view: view)

    }    
    
    // MARK: - Video Layer.
    
    private func videoPlayLayer(view: UIView) {
    
        // player Layer.
        player = AVPlayer(playerItem: self.videoPlayerItem)
        player?.volume = 1
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        view.layer.addSublayer(playerLayer!)

        crossButton.layer.zPosition = 1
        sendStore.layer.zPosition = 1
        self.playButton.layer.zPosition = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.videoPlayerItem)
        
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        self.playButton.isHidden = false
    }
    

    
    // MARK: - IBActions.
    
    @IBAction func playVideoButtonaction(_ sender: Any) {
        
        self.playButton.isHidden = true

        player?.seek(to: kCMTimeZero)
        player?.play()
        
    }
    
    @IBAction func removeViewButton(_ sender: Any?) {
        // Remove Self View
        self.removeFromSuperview()
    }
    
    
    @IBAction func sendStoreButton(_ sender: Any?) {
        delegate?.uploadVideoAndImage(isShowImage: (storeInfoObj?.isShowImage)!, image: storeInfoObj?.image, videoURL: storeInfoObj?.videoURL, view: self)
    }
    
}

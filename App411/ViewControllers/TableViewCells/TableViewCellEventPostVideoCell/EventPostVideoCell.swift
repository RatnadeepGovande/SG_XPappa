//
//  EventPostVideoCell.swift
//  App411
//
//  Created by osvinuser on 8/2/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import AVFoundation

protocol EventPostVideoCellDelegate {
    func isLikedVideoAction(_ sender: UIButton)
}

class EventPostVideoCell: UITableViewCell {

    @IBOutlet var videoView: UIView!
    @IBOutlet var contentLabel: ActiveLabel!
    @IBOutlet var likeButton: DesignableButton!
    @IBOutlet var nameLabel: ActiveLabel!
    @IBOutlet var ProfileImage: DesignableImageView!
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    var delegate :EventPostVideoCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupMoviePlayer()

    }
    
    func setupMoviePlayer(){
        
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayer?.volume = 3
        avPlayer?.actionAtItemEnd = .none
        if UIScreen.main.bounds.width == 375 {
            //let widthRequired = self.frame.size.width - 20
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: self.videoView.frame.size.width, height: self.videoView.frame.size.height)
        }else if UIScreen.main.bounds.width == 320 {
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: self.videoView.frame.size.width, height: self.videoView.frame.size.height)
            
        }else{
            let widthRequired = self.frame.size.width
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: self.videoView.frame.size.width, height: self.videoView.frame.size.height)
        }
        
        self.videoView.layer.insertSublayer(avPlayerLayer!, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        //self.avPlayer?.play()
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
    @IBAction func clickOnLikeButton(_ sender: UIButton) {
        self.delegate?.isLikedVideoAction(sender)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

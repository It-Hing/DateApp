//
//  avPlayerViewController.swift
//  drink
//
//  Created by user on 09/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

class avPlayerViewController:UIViewController{
    
    @IBOutlet weak var sizeView: UIView!//firstPage의 영상을 위한 사이즈뷰
    @IBOutlet weak var sizeView2: UIView!//임시로그인화면의 영상을 위한 사이즈뷰
    
    var playerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideo()
        
    }
    
    override func viewDidLayoutSubviews() {
        if sizeView != nil{
            playerLayer!.frame = sizeView.frame
        }else{
            playerLayer!.frame = sizeView2.frame
        }
    }
    
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "오늘_소개영상", ofType:"mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //print(playerLayer?.frame)
        self.view!.layer.addSublayer(playerLayer!)
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
}

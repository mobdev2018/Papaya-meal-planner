//
//  VideoViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/28/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import UIKit
import YouTubePlayer
import Alamofire
import SwiftKeychainWrapper

class VideoViewController: UIViewController, YouTubePlayerDelegate {

    @IBOutlet weak var playerView: YouTubePlayerView!
    
    var videoUrl: String!
    var id: Int!
    
    var stopTime: Double = 0
    var finishedVideo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.delegate = self
        
        self.view.backgroundColor = UIColor.black
        
        // Load video from YouTube URL
        let myVideoURL = URL(string: videoUrl)
        playerView.loadVideoURL(myVideoURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show status bar again after dismiss
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func onDoneButton(_ sender: UIBarButtonItem) {
        if !finishedVideo {
            contentView(id: id, stopTime: "\(Int(round(stopTime)))")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func contentView(id: Int, stopTime: String) {
        
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        let parameters: Parameters = ["action": "content_view", "meta": stopTime]
        
        contentAction(contentId: id, parameters: parameters, headers: headers) { response in
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        playerView.play()
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        let rawValue = playerState.rawValue
        
        if rawValue == "0" {
            finishedVideo = true
            
            if let duration = videoPlayer.getDuration() {
                if let seconds = Double(duration) {
                    print(Int(round(seconds)))
                    contentView(id: id, stopTime: "\(Int(round(seconds)))")
                }
            }
        } else if rawValue == "2" {
            if let duration = videoPlayer.getCurrentTime() {
                if let seconds = Double(duration) {
                    stopTime = seconds
                }
            }
        }
        
    }

}

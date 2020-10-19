//
//  ViewController.swift
//  ExampleAVPlayer
//
//  Created by Andreu Santaren on 18/10/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import UIKit
import AVKit
import OpenAVT_Core
import OpenAVT_AVPlayer

class ViewController: UIViewController {

    var playerViewController: AVPlayerViewController?
    var instrument: OAVTInstrument?
    var avpTrackerId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Activate logs
        OAVTLog.setLogLevel(OAVTLog.LogLevel.Verbose)
    }
    
    // When the player controller is closed, unregister tracker listeners and send a STOP event.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let playerViewController = self.playerViewController {
            if playerViewController.isBeingDismissed {
                if let tracker = self.instrument?.getTracker(self.avpTrackerId ?? 0) as? OAVTTrackerAVPlayer {
                    self.instrument?.emit(action: OAVTAction.STOP, tracker: tracker)
                    tracker.unregisterListeners()
                }
            }
        }
    }

    @IBAction func clickBunnyVideo(_ sender: Any) {
        playVideo("http://docs.evostream.com/sample_content/assets/hls-bunny-rangerequest/playlist.m3u8")
    }
    
    @IBAction func clickSintelVideo(_ sender: Any) {
        playVideo("https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
    }
    
    @IBAction func clickAirshowLive(_ sender: Any) {
        playVideo("http://cdn3.viblast.com/streams/hls/airshow/playlist.m3u8")
    }
    
    @IBAction func clickAppleConferene(_ sender: Any) {
        playVideo("http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8")
    }
    
    @IBAction func clickGearExample(_ sender: Any) {
        playVideo("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")
    }
    
    // Open a new player controller and start tracking it
    func playVideo(_ videoSource: String) {
        OAVTLog.debug("---> Start playing = \(videoSource)")
        
        let videoURL = URL(string: videoSource)
        let asset = AVURLAsset(url: videoURL!)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        setupInstrument(player: player)
        
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        playerViewController?.showsPlaybackControls = true
        
        self.present(playerViewController!, animated: true) {
            OAVTLog.debug("---> Call Play")
            self.playerViewController?.player!.play()
        }
    }
    
    // Create an OpenAVT Instrument to track the AVPlayer instance
    func setupInstrument(player: AVPlayer!) {
        self.instrument = OAVTInstrument(hub: OAVTHubCore(), backend: DummyBackend())
        self.avpTrackerId = self.instrument?.addTracker(OAVTTrackerAVPlayer(player: player))
        self.instrument?.ready()
    }
    
    // Create an OpenAVT Instrument to track the AVPlayer instance
    func xxxsetupInstrument(player: AVPlayer!) {
        let instrument = OAVTInstrument(hub: OAVTHubCore(), backend: DummyBackend())
        let avpTrackerId = instrument.addTracker(OAVTTrackerAVPlayer(player: player))
        instrument.ready()
    }
}


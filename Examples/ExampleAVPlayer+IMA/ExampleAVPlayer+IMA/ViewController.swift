//
//  ViewController.swift
//  ExampleAVPlayer+IMA
//
//  Created by Andreu Santaren on 19/10/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import UIKit
import AVKit
import GoogleInteractiveMediaAds
import OpenAVT_Core
import OpenAVT_AVPlayer
import OpenAVT_IMA

class ViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {

    @IBOutlet weak var adsSwitch: UISwitch!
    
    var instrument: OAVTInstrument?
    var avpTrackerId: Int?
    var imaTrackerId: Int?
    var playerViewController: AVPlayerViewController?
    
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    // 1 Pre-roll Ad
    let singleAdTagURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="
    // 1 Pre-roll and 3 mid-roll Ads
    let multipleAdTagURL = "http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=xml_vmap1&unviewed_position_start=1&cust_params=sample_ar%3Dpremidpostpod%26deployment%3Dgmf-js&cmsid=496&vid=short_onecue&correlator="
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        OAVTLog.setLogLevel(OAVTLog.LogLevel.Verbose)
    }
    
    @objc func appDidBecomeActive() {
        if adsManager != nil {
            adsManager.resume()
        }
    }
    
    func playVideo(_ videoSource: String) {
        OAVTLog.verbose("---> Start playing = \(videoSource)")
        
        setupInstrument()
        
        self.instrument?.emit(action: OAVTAction.MEDIA_REQUEST, trackerId: self.avpTrackerId ?? 0)
        
        let videoURL = URL(string: videoSource)
        let asset = AVURLAsset(url: videoURL!)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        if let tracker = self.instrument?.getTracker(self.avpTrackerId ?? 0) as? OAVTTrackerAVPlayer {
            tracker.setPlayer(player)
        }
        
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        playerViewController?.showsPlaybackControls = true
        
        if self.adsSwitch.isOn {
            self.setupAds(player: player)
        }
        
        self.present(playerViewController!, animated: true) {
            OAVTLog.verbose("---> Call Play")
            self.playerViewController?.player!.play()
            if self.adsSwitch.isOn {
                self.requestAds()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let playerViewController = self.playerViewController {
            if playerViewController.isBeingDismissed {
                if let tracker = self.instrument?.getTracker(self.avpTrackerId ?? 0) as? OAVTTrackerAVPlayer {
                    self.instrument?.emit(action: OAVTAction.STOP, tracker: tracker)
                    self.instrument?.shutdown()
                    if self.adsSwitch.isOn {
                        self.releaseAds()
                    }
                }
            }
        }
    }
    
    func setupAds(player: AVPlayer) {
        // Set up IMA stuff
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
    }
    
    func requestAds() {
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: (self.playerViewController?.view)!, viewController: self.playerViewController)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: multipleAdTagURL,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader.requestAds(with: request)
    }
    
    func releaseAds() {
        adsLoader.contentComplete()
        if adsManager != nil {
            adsManager!.destroy()
            adsManager = nil
        }
        adsLoader = nil
    }
    
    func setupInstrument() {
        self.instrument = OAVTInstrument(hub: OAVTHubCoreAds(), backend: DummyBackend())
        self.avpTrackerId = self.instrument?.addTracker(OAVTTrackerAVPlayer())
        self.imaTrackerId = self.instrument?.addTracker(OAVTTrackerIMA())
        self.instrument?.ready()
    }
    
    // MARK: - IMAAdsLoaderDelegate
    
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        if adsManager != nil {
            adsManager!.destroy()
            adsManager = nil
        }
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        adsManager.initialize(with: nil)
        print("Ads Loader Loaded Data")
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error loading ads: " + adErrorData.adError.message)
        
        if let imaTracker : OAVTTrackerIMA = self.instrument?.getTracker(imaTrackerId!) as? OAVTTrackerIMA {
            imaTracker.adError(message: adErrorData.adError.message)
        }
        
        self.playerViewController?.player?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if let imaTracker : OAVTTrackerIMA = self.instrument?.getTracker(imaTrackerId!) as? OAVTTrackerIMA {
            imaTracker.adEvent(event: event, adsManager: adsManager)
        }
        
        if event.type == IMAAdEventType.LOADED {
            print("Ads Manager call start()")
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        print("Error managing ads: " + error.message)
        
        if let imaTracker : OAVTTrackerIMA = self.instrument?.getTracker(imaTrackerId!) as? OAVTTrackerIMA {
            imaTracker.adError(message: error.message)
        }
        
        self.playerViewController?.player?.play()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        print("Ads request pause")
        
        if let imaTracker : OAVTTrackerIMA = self.instrument?.getTracker(imaTrackerId!) as? OAVTTrackerIMA {
            imaTracker.adBreakBegin()
        }
        
        self.playerViewController?.player?.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        print("Ads request resume")
        
        if let imaTracker : OAVTTrackerIMA = self.instrument?.getTracker(imaTrackerId!) as? OAVTTrackerIMA {
            imaTracker.adBreakFinish()
        }
        
        self.playerViewController?.player?.play()
    }

}


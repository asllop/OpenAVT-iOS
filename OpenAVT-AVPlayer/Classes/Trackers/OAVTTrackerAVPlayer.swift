//
//  OAVTTrackerAVPlayer.swift
//  OpenAVT-AVPlayer
//
//  Created by Andreu Santaren on 26/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation
import AVKit
import OpenAVT_Core

open class OAVTTrackerAVPlayer : NSObject, OAVTTrackerProtocol {
    
    public var state = OAVTState()
    public var trackerId: Int?
    
    private weak var instrument: OAVTInstrument?
    private weak var player: AVPlayer?
    
    private var lastError: NSError?
    private var timeObserver: Any?
    private var pauseBeginPosition: Int?
    private var lastResolutionHeight: Int = 0
    private var lastResolutionWidth: Int = 0

    public convenience init(player: AVPlayer) {
        self.init()
        self.setPlayer(player)
    }
    
    public override init() {
        super.init()
    }
    
    deinit {
        OAVTLog.verbose("##### OAVTTrackerAVPlayer deinit")
    }
    
    open func setPlayer(_ player: AVPlayer) {
        if self.player != nil {
            unregisterListeners()
        }
        self.player = player
        self.instrument?.emit(action: OAVTAction.PLAYER_SET, tracker: self)
        registerListeners()
    }
    
    open func initEvent(event: OAVTEvent) -> OAVTEvent? {
        // Set event specific attributes
        if event.getAction() == OAVTAction.ERROR {
            if let error = self.lastError {
                event.setAttribute(key: OAVTAttribute.ERROR_DESCRIPTION, value: error.userInfo["NSDescription"] ?? error.localizedDescription)
            }
            self.lastError = nil
        }
        else if event.getAction() == OAVTAction.START {
            self.instrument?.startPing(trackerId: self.trackerId!, interval: 30.0)
        }
        else if event.getAction() == OAVTAction.END || event.getAction() == OAVTAction.STOP {
            self.instrument?.stopPing(trackerId: trackerId!)
        }
        
        // Set attributes from getters
        self.instrument?.useGetter(attribute: OAVTAttribute.TRACKER_TARGET, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.POSITION, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.DURATION, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.RESOLUTION_HEIGHT, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.RESOLUTION_WIDTH, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.IS_MUTED, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.VOLUME, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.FPS, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.SOURCE, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.BITRATE, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.LANGUAGE, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.SUBTITLES, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.IS_ADS_TRACKER, event: event, tracker: self)
        
        return event
    }
    
    open func getState() -> OAVTState {
        return self.state
    }
    
    open func instrumentReady(instrument: OAVTInstrument) {
        if self.instrument == nil {
            self.instrument = instrument
            registerGetters()
            self.instrument?.emit(action: OAVTAction.TRACKER_INIT, tracker: self)
        }
    }
    
    open func endOfService() {
        unregisterListeners()
    }
    
    open func registerGetters() {
        self.instrument?.registerGetter(attribute: OAVTAttribute.TRACKER_TARGET, getter: self.getTrackerTarget, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.POSITION, getter: self.getPosition, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.DURATION, getter: self.getDuration, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.RESOLUTION_HEIGHT, getter: self.getResolutionHeight, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.RESOLUTION_WIDTH, getter: self.getResolutionWidth, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.IS_MUTED, getter: self.getIsMuted, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.VOLUME, getter: self.getVolume, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.FPS, getter: self.getFps, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.SOURCE, getter: self.getSource, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.BITRATE, getter: self.getBitrate, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.LANGUAGE, getter: self.getLanguage, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.SUBTITLES, getter: self.getSubtitles, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.IS_ADS_TRACKER, getter: self.getIsAdsTracker, tracker: self)
    }
    
    open func registerListeners() {
        OAVTLog.verbose("---> AVPlayer register listeners")
        
        if let player = self.player {
            NotificationCenter.default.addObserver(self, selector: #selector(self.itemTimeJumpedNotification), name: NSNotification.Name.AVPlayerItemTimeJumped, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidPlayToEndTimeNotification), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.itemFailedToPlayToEndTimeNotification), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
            
            player.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
            player.addObserver(self, forKeyPath: "rate", options: [.new], context: nil)
            player.addObserver(self, forKeyPath: "currentItem.status", options: [.new], context: nil)
            player.addObserver(self, forKeyPath: "currentItem.playbackBufferEmpty", options: [.new], context: nil)
            player.addObserver(self, forKeyPath: "currentItem.playbackBufferFull", options: [.new], context: nil)
            player.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: [.new], context: nil)
            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
            player.addObserver(self, forKeyPath: "reasonForWaitingToPlay", options: [.new], context: nil)
            player.addObserver(self, forKeyPath: "currentItem", options: [.new], context: nil)
            
            let timeScale = CMTimeScale(NSEC_PER_SEC)
            let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

            timeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: nil) { (time) in
                
                self.checkResolutionChange()
                
                //TODO: Does AVPlayeer support backward playback and fast forward/rewind? In these cases the rate will be either negative or greater than 1.
                
                if player.rate == 1.0 {
                    if self.getState().didStart == false {
                        self.instrument?.emit(action: OAVTAction.START, tracker: self)
                    }
                    if self.getState().isSeeking == true {
                        self.instrument?.emit(action: OAVTAction.SEEK_FINISH, tracker: self)
                    }
                    if self.getState().isPaused == true {
                        self.instrument?.emit(action: OAVTAction.PAUSE_FINISH, tracker: self)
                    }
                }
                else if player.rate == 0.0 {
                    if self.getState().isPaused == false {
                        self.pauseBeginPosition = self.getPosition()
                        self.instrument?.emit(action: OAVTAction.PAUSE_BEGIN, tracker: self)
                    }
                }
            }
        }
    }
    
    open func unregisterListeners() {
        OAVTLog.verbose("---> AVPlayer unregister listeners")
        
        if let player = self.player {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
            
            player.removeObserver(self, forKeyPath: "status")
            player.removeObserver(self, forKeyPath: "rate")
            player.removeObserver(self, forKeyPath: "currentItem.status")
            player.removeObserver(self, forKeyPath: "currentItem.playbackBufferEmpty")
            player.removeObserver(self, forKeyPath: "currentItem.playbackBufferFull")
            player.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
            player.removeObserver(self, forKeyPath: "timeControlStatus")
            player.removeObserver(self, forKeyPath: "reasonForWaitingToPlay")
            player.removeObserver(self, forKeyPath: "currentItem")
            
            if let timeObserver = timeObserver {
                player.removeTimeObserver(timeObserver)
                self.timeObserver = nil
            }
        }
    }
    
    @objc private func itemTimeJumpedNotification(notification: NSNotification) {
        OAVTLog.verbose("---> itemTimeJumpedNotification")
    }
    
    @objc private func itemDidPlayToEndTimeNotification(notification: NSNotification) {
        OAVTLog.verbose("---> itemDidPlayToEndTimeNotification")
        if !self.getState().inAdBreak {
            self.instrument?.emit(action: OAVTAction.END, tracker: self)
        }
    }
    
    @objc private func itemFailedToPlayToEndTimeNotification(notification: NSNotification) {
        OAVTLog.verbose("---> itemFailedToPlayToEndTimeNotification")
        self.lastError = self.player?.error as NSError?
        if self.lastError == nil {
            self.lastError = self.player?.currentItem?.error as NSError?
        }
        self.instrument?.emit(action: OAVTAction.ERROR, tracker: self)
        self.instrument?.stopPing(trackerId: trackerId!)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        OAVTLog.verbose("---> Keypath = \(keyPath ?? "") , new = \(change?[NSKeyValueChangeKey(rawValue: "new")] ?? "")")
        
        switch keyPath ?? "" {
        case "status":
            if self.player?.status == AVPlayer.Status.readyToPlay {
                self.instrument?.emit(action: OAVTAction.STREAM_LOAD, tracker: self)
            }
            else if self.player?.status == AVPlayer.Status.failed {
                self.lastError = self.player?.error as NSError?
                self.instrument?.emit(action: OAVTAction.ERROR, tracker: self)
            }
        case "currentItem.status":
            if self.player?.currentItem?.status == AVPlayerItem.Status.failed {
                self.lastError = self.player?.currentItem?.error as NSError?
                self.instrument?.emit(action: OAVTAction.ERROR, tracker: self)
            }
        case "timeControlStatus":
            if #available(iOS 10.0, *) {
                switch self.player?.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    OAVTLog.verbose("---> timeControlStatus waitingToPlayAtSpecifiedRate")
                    self.instrument?.emit(action: OAVTAction.BUFFER_BEGIN, tracker: self)
                    switch self.player?.reasonForWaitingToPlay {
                    case AVPlayer.WaitingReason.toMinimizeStalls:
                        OAVTLog.verbose("---> reasonForWaitingToPlay toMinimizeStalls")
                    case AVPlayer.WaitingReason.noItemToPlay:
                        OAVTLog.verbose("---> reasonForWaitingToPlay noItemToPlay")
                    case AVPlayer.WaitingReason.evaluatingBufferingRate:
                        OAVTLog.verbose("---> reasonForWaitingToPlay evaluatingBufferingRate")
                    default:
                        OAVTLog.verbose("---> reasonForWaitingToPlay other")
                    }
                case .paused:
                    OAVTLog.verbose("---> timeControlStatus pause")
                    self.instrument?.emit(action: OAVTAction.BUFFER_FINISH, tracker: self)
                case .playing:
                    OAVTLog.verbose("---> timeControlStatus playing")
                    self.instrument?.emit(action: OAVTAction.BUFFER_FINISH, tracker: self)
                default:
                    OAVTLog.verbose("---> timeControlStatus other")
                }
            } else {
                // Fallback on earlier versions
            }
        case "currentItem.playbackBufferEmpty":
            if self.getState().isPaused == true {
                OAVTLog.verbose("Current position = \(getPosition() ?? 0) , PauseBeginPosition = \(self.pauseBeginPosition ?? 0)")
                if let pos = getPosition(), let pausePos = self.pauseBeginPosition {
                    if pos > pausePos {
                        self.instrument?.emit(action: OAVTAction.SEEK_BEGIN, tracker: self)
                    }
                }
            }
        default:
            OAVTLog.verbose("Nothing to do")
        }
    }
    
    private func checkResolutionChange() {
        if let currH = getResolutionHeight(), let currW = getResolutionWidth() {
            if lastResolutionWidth == 0 || lastResolutionHeight == 0 {
                lastResolutionHeight = currH
                lastResolutionWidth = currW
            }
            else {
                let lastMul = lastResolutionHeight * lastResolutionWidth
                let currMul = currH * currW
                
                if lastMul > currMul {
                    self.instrument?.emit(action: OAVTAction.QUALITY_CHANGE_DOWN, tracker: self)
                }
                else if lastMul < currMul {
                    self.instrument?.emit(action: OAVTAction.QUALITY_CHANGE_UP, tracker: self)
                }
                
                lastResolutionHeight = currH
                lastResolutionWidth = currW
            }
        }
    }
    
    // MARK: - Attribute Getters
    
    open func getTrackerTarget() -> String {
        return "AVPlayer"
    }
    
    open func getPosition() -> Int? {
        if let player = self.player {
            if let currentTime = player.currentItem?.currentTime() {
                let position = CMTimeGetSeconds(currentTime)
                if !position.isNaN {
                    return Int(position * 1000)
                }
            }
        }
        return nil
    }
    
    open func getDuration() -> Int? {
        if let player = self.player {
            if let duration = player.currentItem?.duration {
                let timeDuration = CMTimeGetSeconds(duration)
                if !timeDuration.isNaN {
                    return Int(timeDuration * 1000)
                }
            }
        }
        return nil
    }
    
    open func getResolutionHeight() -> Int? {
        if let player = self.player {
            if let height = player.currentItem?.presentationSize.height {
                return Int(height)
            }
        }
        return nil
    }
    
    open func getResolutionWidth() -> Int? {
        if let player = self.player {
            if let width = player.currentItem?.presentationSize.width {
                return Int(width)
            }
        }
        return nil
    }
    
    open func getIsMuted() -> Bool? {
        if let player = self.player {
            return player.isMuted
        }
        return nil
    }
    
    open func getVolume() -> Int? {
        if let player = self.player {
            return Int(player.volume * 100)
        }
        return  nil
    }
    
    open func getFps() -> Float? {
        if let player = self.player {
            if let asset = player.currentItem?.asset {
                var error: NSError? = nil
                let kvostatus = asset.statusOfValue(forKey: "tracks", error: &error)
                if kvostatus == .loaded {
                    if let videoTrack = asset.tracks(withMediaType: .video).last {
                        return videoTrack.nominalFrameRate
                    }
                }
            }
        }
        return nil;
    }
    
    open func getSource() -> String? {
        if let player = self.player {
            if let asset = player.currentItem?.asset {
                if asset.isKind(of: AVURLAsset.self) {
                    return (asset as! AVURLAsset).url.absoluteString
                }
            }
        }
        return nil;
    }
    
    open func getBitrate() -> Int? {
        if let player = self.player {
            if let event = player.currentItem?.accessLog()?.events.last {
                if !event.observedBitrate.isNaN {
                    return Int(event.observedBitrate)
                }
            }
        }
        return  nil
    }
    
    open func getLanguage() -> String? {
        if let player = self.player {
            if let asset = player.currentItem?.asset {
                if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) {
                    if #available(iOS 9.0, *) {
                        let selectedOption = player.currentItem?.currentMediaSelection.selectedMediaOption(in: group)
                        if let locale = selectedOption?.locale {
                            return locale.languageCode
                        }
                    }
                }
            }
        }
        return  nil
    }
    
    open func getSubtitles() -> String? {
        if let player = self.player {
            if let asset = player.currentItem?.asset {
                if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
                    if #available(iOS 9.0, *) {
                        let selectedOption = player.currentItem?.currentMediaSelection.selectedMediaOption(in: group)
                        if let locale = selectedOption?.locale {
                            return locale.languageCode
                        }
                    }
                }
            }
        }
        return  nil
    }
    
    //TODO: get title (https://developer.apple.com/documentation/avfoundation/media_assets_and_metadata/finding_metadata_values)
    
    open func getIsAdsTracker() -> Bool {
        return false
    }
}

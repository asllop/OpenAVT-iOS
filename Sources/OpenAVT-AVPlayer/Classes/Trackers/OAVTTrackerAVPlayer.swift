//
//  OAVTTrackerAVPlayer.swift
//  OpenAVT-AVPlayer
//
//  Created by asllop on 26/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation
import AVKit
import OpenAVT_Core

/// OAVT tracker for AVPlayer.
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
        self.instrument?.emit(action: OAVTAction.PlayerSet, tracker: self)
        registerListeners()
    }
    
    open func initEvent(event: OAVTEvent) -> OAVTEvent? {
        // Set event specific attributes
        if event.getAction() == OAVTAction.Error {
            if let error = self.lastError {
                event.setAttribute(key: OAVTAttribute.errorDescription, value: error.userInfo["NSDescription"] ?? error.localizedDescription)
            }
            self.lastError = nil
        }
        
        return event
    }
    
    open func getState() -> OAVTState {
        return self.state
    }
    
    open func instrumentReady(instrument: OAVTInstrument) {
        if self.instrument == nil {
            self.instrument = instrument
            registerGetters()
            self.instrument?.emit(action: OAVTAction.TrackerInit, tracker: self)
        }
    }
    
    open func endOfService() {
        unregisterListeners()
    }
    
    open func registerGetters() {
        self.instrument?.registerGetter(attribute: OAVTAttribute.trackerTarget, getter: self.getTrackerTarget, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.position, getter: self.getPosition, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.duration, getter: self.getDuration, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.resolutionHeight, getter: self.getResolutionHeight, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.resolutionWidth, getter: self.getResolutionWidth, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.isMuted, getter: self.getIsMuted, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.volume, getter: self.getVolume, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.fps, getter: self.getFps, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.source, getter: self.getSource, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.bitrate, getter: self.getBitrate, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.language, getter: self.getLanguage, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.subtitles, getter: self.getSubtitles, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.isAdsTracker, getter: self.getIsAdsTracker, tracker: self)
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
                        self.instrument?.emit(action: OAVTAction.Start, tracker: self)
                    }
                    if self.getState().isSeeking == true {
                        self.instrument?.emit(action: OAVTAction.SeekFinish, tracker: self)
                    }
                    if self.getState().isPaused == true {
                        self.instrument?.emit(action: OAVTAction.PauseFinish, tracker: self)
                    }
                }
                else if player.rate == 0.0 {
                    if self.getState().isPaused == false {
                        self.pauseBeginPosition = self.getPosition()
                        self.instrument?.emit(action: OAVTAction.PauseBegin, tracker: self)
                    }
                }
            }
        }
        
        self.instrument?.emit(action: OAVTAction.PlayerReady, tracker: self)
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
            self.instrument?.emit(action: OAVTAction.End, tracker: self)
        }
    }
    
    @objc private func itemFailedToPlayToEndTimeNotification(notification: NSNotification) {
        OAVTLog.verbose("---> itemFailedToPlayToEndTimeNotification")
        self.lastError = self.player?.error as NSError?
        if self.lastError == nil {
            self.lastError = self.player?.currentItem?.error as NSError?
        }
        self.instrument?.emit(action: OAVTAction.Error, tracker: self)
        self.instrument?.stopPing(trackerId: trackerId!)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        OAVTLog.verbose("---> Keypath = \(keyPath ?? "") , new = \(change?[NSKeyValueChangeKey(rawValue: "new")] ?? "")")
        
        switch keyPath ?? "" {
        case "status":
            if self.player?.status == AVPlayer.Status.readyToPlay {
                self.instrument?.emit(action: OAVTAction.StreamLoad, tracker: self)
            }
            else if self.player?.status == AVPlayer.Status.failed {
                self.lastError = self.player?.error as NSError?
                self.instrument?.emit(action: OAVTAction.Error, tracker: self)
            }
        case "currentItem.status":
            if self.player?.currentItem?.status == AVPlayerItem.Status.failed {
                self.lastError = self.player?.currentItem?.error as NSError?
                self.instrument?.emit(action: OAVTAction.Error, tracker: self)
            }
        case "timeControlStatus":
            if #available(iOS 10.0, *) {
                switch self.player?.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    OAVTLog.verbose("---> timeControlStatus waitingToPlayAtSpecifiedRate")
                    self.instrument?.emit(action: OAVTAction.BufferBegin, tracker: self)
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
                    self.instrument?.emit(action: OAVTAction.BufferFinish, tracker: self)
                case .playing:
                    OAVTLog.verbose("---> timeControlStatus playing")
                    self.instrument?.emit(action: OAVTAction.BufferFinish, tracker: self)
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
                        self.instrument?.emit(action: OAVTAction.SeekBegin, tracker: self)
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
                    self.instrument?.emit(action: OAVTAction.QualityChangeDown, tracker: self)
                }
                else if lastMul < currMul {
                    self.instrument?.emit(action: OAVTAction.QualityChangeUp, tracker: self)
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

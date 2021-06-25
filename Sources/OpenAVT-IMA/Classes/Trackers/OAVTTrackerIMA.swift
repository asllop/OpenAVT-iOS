//
//  OAVTTrackerIMA.swift
//  OpenAVT-IMA
//
//  Created by asllop on 04/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation
import GoogleInteractiveMediaAds
import OpenAVT_Core

/// OAVT tracker for Google IMA ads.
open class OAVTTrackerIMA : OAVTTrackerProtocol {
    
    public var state = OAVTState()
    public var trackerId: Int?
    
    private weak var instrument: OAVTInstrument?
    private weak var lastEvent: IMAAdEvent?
    private weak var adsManager: IMAAdsManager?
    private var errorMessage: String?
    
    public init() {}
    
    deinit {
        OAVTLog.verbose("##### OAVTTrackerIMA deinit")
    }
    
    open func initEvent(event: OAVTEvent) -> OAVTEvent? {
        // Set event specific attributes
        if event.getAction() == OAVTAction.AdError {
            if let error = self.errorMessage {
                event.setAttribute(key: OAVTAttribute.errorDescription, value: error)
            }
            self.errorMessage = nil
        }
        
        self.instrument?.useGetter(attribute: OAVTAttribute.trackerTarget, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adPosition, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adDuration, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adBufferedTime, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adVolume, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adRoll, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adDescription, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adId, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adTitle, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adAdvertiserName, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adCreativeId, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adBitrate, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adResolutionWidth, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adResolutionHeight, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.adSystem, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.isAdsTracker, event: event, tracker: self)
        
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
    }
    
    open func registerGetters() {
        self.instrument?.registerGetter(attribute: OAVTAttribute.trackerTarget, getter: self.getTrackerTarget, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adPosition, getter: self.getAdPosition, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adDuration, getter: self.getAdDuration, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adBufferedTime, getter: self.getAdBufferedTime, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adVolume, getter: self.getAdVolume, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adRoll, getter: self.getAdRoll, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adDescription, getter: self.getAdDescription, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adId, getter: self.getAdId, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adTitle, getter: self.getAdTitle, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adAdvertiserName, getter: self.getAdAdvertiserName, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adCreativeId, getter: self.getAdCreativeID, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adBitrate, getter: self.getAdBitrate, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adResolutionWidth, getter: self.getAdWidth, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adResolutionHeight, getter: self.getAdHeight, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.adSystem, getter: self.getAdSystem, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.isAdsTracker, getter: self.getIsAdsTracker, tracker: self)
    }
    
    open func adBreakBegin() {
        self.instrument?.emit(action: OAVTAction.AdBreakBegin, tracker: self)
    }
    
    open func adBreakFinish() {
        self.instrument?.emit(action: OAVTAction.AdBreakFinish, tracker: self)
    }

    open func adEvent(event: IMAAdEvent, adsManager: IMAAdsManager? = nil) {
        self.lastEvent = event
        self.adsManager = adsManager
        switch event.typeString {
        case "Started":
            self.instrument?.emit(action: OAVTAction.AdBegin, tracker: self)
        case "Complete":
            self.instrument?.emit(action: OAVTAction.AdFinish, tracker: self)
        case "First Quartile":
            self.instrument?.emit(action: OAVTAction.AdFirstQuartile, tracker: self)
        case "Midpoint":
            self.instrument?.emit(action: OAVTAction.AdSecondQuartile, tracker: self)
        case "Third Quartile":
            self.instrument?.emit(action: OAVTAction.AdThirdQuartile, tracker: self)
        case "Tapped", "Clicked":
            self.instrument?.emit(action: OAVTAction.AdClick, tracker: self)
        case "Skipped":
            self.instrument?.emit(action: OAVTAction.AdSkip, tracker: self)
        case "Pause":
            self.instrument?.emit(action: OAVTAction.AdPauseBegin, tracker: self)
        case "Resume":
            self.instrument?.emit(action: OAVTAction.AdPauseFinish, tracker: self)
        default:
            OAVTLog.verbose("Not handled event")
        }
        
        OAVTLog.verbose("Ads manager did Receive Event = \(event.typeString ?? "")")
    }
    
    open func adError(message: String) {
        self.errorMessage = message
        self.instrument?.emit(action: OAVTAction.AdError, tracker: self)
    }
    
    // MARK: - Attribute Getters
    
    open func getTrackerTarget() -> String {
        return "IMA"
    }
    
    open func getAdRoll() -> String? {
        if let event = self.lastEvent {
            switch event.ad.adPodInfo.podIndex {
            case 0:
                return "pre"
            case -1:
                return "post"
            default:
                return "mid"
            }
        }
        return nil
    }
    
    open func getAdPosition() -> Int? {
        if let adsManager = self.adsManager {
            if !adsManager.adPlaybackInfo.currentMediaTime.isNaN && !adsManager.adPlaybackInfo.currentMediaTime.isInfinite {
                return Int(adsManager.adPlaybackInfo.currentMediaTime * 1000)
            }
        }
        return nil
    }
    
    open func getAdDuration() -> Int? {
        if let event = self.lastEvent {
            if !event.ad.duration.isNaN && !event.ad.duration.isInfinite {
                return Int(event.ad.duration * 1000)
            }
        }
        return nil
    }

    open func getAdBufferedTime() -> Int? {
        if let adsManager = self.adsManager {
            if !adsManager.adPlaybackInfo.bufferedMediaTime.isNaN && !adsManager.adPlaybackInfo.bufferedMediaTime.isInfinite {
                return Int(adsManager.adPlaybackInfo.bufferedMediaTime * 1000)
            }
        }
        return nil
    }
    
    open func getAdVolume() -> Int? {
        if let adsManager = self.adsManager {
            return Int(adsManager.volume * 100)
        }
        return nil
    }
    
    open func getAdDescription() -> String? {
        if let event = self.lastEvent {
            return event.ad.adDescription
        }
        return nil
    }
    
    open func getAdId() -> String? {
        if let event = self.lastEvent {
            return event.ad.adId
        }
        return nil
    }
    
    open func getAdTitle() -> String? {
        if let event = self.lastEvent {
            return event.ad.adTitle
        }
        return nil
    }
    
    open func getAdAdvertiserName() -> String? {
        if let event = self.lastEvent {
            if !event.ad.advertiserName.isEmpty {
                return event.ad.advertiserName
            }
        }
        return nil
    }
    
    open func getAdCreativeID() -> String? {
        if let event = self.lastEvent {
            return event.ad.creativeID
        }
        return nil
    }
    
    open func getAdSystem() -> String? {
        if let event = self.lastEvent {
            return event.ad.adSystem
        }
        return nil
    }
    
    open func getAdBitrate() -> Int? {
        if let event = self.lastEvent {
            return event.ad.vastMediaBitrate
        }
        return nil
    }
    
    open func getAdWidth() -> Int? {
        if let event = self.lastEvent {
            return event.ad.vastMediaWidth
        }
        return nil
    }
    
    open func getAdHeight() -> Int? {
        if let event = self.lastEvent {
            return event.ad.vastMediaHeight
        }
        return nil
    }
    
    open func getIsAdsTracker() -> Bool {
        return true
    }
}

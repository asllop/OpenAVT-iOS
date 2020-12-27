//
//  OAVTTrackerIMA.swift
//  OpenAVT-IMA
//
//  Created by Andreu Santaren on 04/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation
import GoogleInteractiveMediaAds
import OpenAVT_Core

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
        if event.getAction() == OAVTAction.AD_ERROR {
            if let error = self.errorMessage {
                event.setAttribute(key: OAVTAttribute.ERROR_DESCRIPTION, value: error)
            }
            self.errorMessage = nil
        }
        
        self.instrument?.useGetter(attribute: OAVTAttribute.TRACKER_TARGET, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_POSITION, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_DURATION, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_BUFFERED_TIME, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_VOLUME, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_ROLL, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_DESCRIPTION, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_ID, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_TITLE, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_ADVERTISER_NAME, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_CREATIVE_ID, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_BITRATE, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_RESOLUTION_WIDTH, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_RESOLUTION_HEIGHT, event: event, tracker: self)
        self.instrument?.useGetter(attribute: OAVTAttribute.AD_SYSTEM, event: event, tracker: self)
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
    }
    
    open func registerGetters() {
        self.instrument?.registerGetter(attribute: OAVTAttribute.TRACKER_TARGET, getter: self.getTrackerTarget, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_POSITION, getter: self.getAdPosition, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_DURATION, getter: self.getAdDuration, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_BUFFERED_TIME, getter: self.getAdBufferedTime, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_VOLUME, getter: self.getAdVolume, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_ROLL, getter: self.getAdRoll, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_DESCRIPTION, getter: self.getAdDescription, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_ID, getter: self.getAdId, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_TITLE, getter: self.getAdTitle, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_ADVERTISER_NAME, getter: self.getAdAdvertiserName, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_CREATIVE_ID, getter: self.getAdCreativeID, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_BITRATE, getter: self.getAdBitrate, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_RESOLUTION_WIDTH, getter: self.getAdWidth, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_RESOLUTION_HEIGHT, getter: self.getAdHeight, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.AD_SYSTEM, getter: self.getAdSystem, tracker: self)
        self.instrument?.registerGetter(attribute: OAVTAttribute.IS_ADS_TRACKER, getter: self.getIsAdsTracker, tracker: self)
    }
    
    open func adBreakBegin() {
        self.instrument?.emit(action: OAVTAction.AD_BREAK_BEGIN, tracker: self)
    }
    
    open func adBreakFinish() {
        self.instrument?.emit(action: OAVTAction.AD_BREAK_FINISH, tracker: self)
    }

    open func adEvent(event: IMAAdEvent, adsManager: IMAAdsManager? = nil) {
        self.lastEvent = event
        self.adsManager = adsManager
        switch event.typeString {
        case "Started":
            self.instrument?.emit(action: OAVTAction.AD_BEGIN, tracker: self)
        case "Complete":
            self.instrument?.emit(action: OAVTAction.AD_FINISH, tracker: self)
        case "First Quartile":
            self.instrument?.emit(action: OAVTAction.AD_FIRST_QUARTILE, tracker: self)
        case "Midpoint":
            self.instrument?.emit(action: OAVTAction.AD_SECOND_QUARTILE, tracker: self)
        case "Third Quartile":
            self.instrument?.emit(action: OAVTAction.AD_THIRD_QUARTILE, tracker: self)
        case "Tapped", "Clicked":
            self.instrument?.emit(action: OAVTAction.AD_CLICK, tracker: self)
        case "Skipped":
            self.instrument?.emit(action: OAVTAction.AD_SKIP, tracker: self)
        case "Pause":
            self.instrument?.emit(action: OAVTAction.AD_PAUSE_BEGIN, tracker: self)
        case "Resume":
            self.instrument?.emit(action: OAVTAction.AD_PAUSE_FINISH, tracker: self)
        default:
            OAVTLog.verbose("Not handled event")
        }
        
        OAVTLog.verbose("Ads manager did Receive Event = \(event.typeString ?? "")")
    }
    
    open func adError(message: String) {
        self.errorMessage = message
        self.instrument?.emit(action: OAVTAction.AD_ERROR, tracker: self)
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

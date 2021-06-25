//
//  OAVTHubAds.swift
//  OpenAVT-Core
//
//  Created by asllop on 04/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OAVT hub for generic content players with ads.
open class OAVTHubCoreAds : OAVTHubCore {
    
    private var countAds = 0
    private weak var instrument: OAVTInstrument?
    
    open override func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent? {
        if event.getAction() == OAVTAction.AdBreakBegin {
            setInAdBreakState(state: true)
        }
        else if event.getAction() == OAVTAction.AdBreakFinish {
            if tracker.getState().inAdBreak {
                setInAdBreakState(state: false)
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.AdBegin {
            self.instrument?.startPing(trackerId: tracker.trackerId!, interval: 30.0)
            setInAdState(state: true)
            countAds = countAds + 1
        }
        else if event.getAction() == OAVTAction.AdFinish {
            self.instrument?.stopPing(trackerId: tracker.trackerId!)
            if tracker.getState().inAd {
                setInAdState(state: false)
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.End {
            // To avoid content end when an ad break happens
            if tracker.getState().inAdBreak {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.AdPauseBegin {
            if !tracker.getState().isPaused {
                tracker.getState().isPaused = true
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.AdPauseFinish {
            if tracker.getState().isPaused {
                tracker.getState().isPaused = false
            }
            else {
                return nil
            }
        }
        
        event.setAttribute(key: OAVTAttribute.inAdBreakBlock, value: tracker.getState().inAdBreak)
        event.setAttribute(key: OAVTAttribute.inAdBlock, value: tracker.getState().inAd)
        event.setAttribute(key: OAVTAttribute.countAds, value: countAds)
        
        // Get current content video position
        if let trackers = self.instrument?.getTrackers() {
            for (_, tracker) in trackers {
                if let isAdsTracker = self.instrument?.callGetter(attribute: OAVTAttribute.isAdsTracker, tracker: tracker) as? Bool {
                    if !isAdsTracker {
                        instrument?.useGetter(attribute: OAVTAttribute.position, event: event, tracker: tracker)
                    }
                }
            }
        }
        
        return super.processEvent(event: event, tracker: tracker)
    }
    
    open override func instrumentReady(instrument: OAVTInstrument) {
        super.instrumentReady(instrument: instrument)
        self.instrument = instrument
    }
    
    /// Set inAd state for all trackers of the instrument
    open func setInAdState(state: Bool) {
        if let trackers = self.instrument?.getTrackers() {
            for (_, tracker) in trackers {
                tracker.getState().inAd = state
            }
        }
    }
    
    /// Set inAdBreak state for all trackers of the instrument
    open func setInAdBreakState(state: Bool) {
        if let trackers = self.instrument?.getTrackers() {
            for (_, tracker) in trackers {
                tracker.getState().inAdBreak = state
            }
        }
    }
}

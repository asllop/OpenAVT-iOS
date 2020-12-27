//
//  OAVTHubAds.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 04/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

open class OAVTHubCoreAds : OAVTHubCore {
    
    private var countAds = 0
    private weak var instrument: OAVTInstrument?
    
    open override func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent? {
        if event.getAction() == OAVTAction.AD_BREAK_BEGIN {
            setInAdBreakState(state: true)
        }
        else if event.getAction() == OAVTAction.AD_BREAK_FINISH {
            if tracker.getState().inAdBreak {
                setInAdBreakState(state: false)
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.AD_BEGIN {
            self.instrument?.startPing(trackerId: tracker.trackerId!, interval: 30.0)
            setInAdState(state: true)
            countAds = countAds + 1
        }
        else if event.getAction() == OAVTAction.AD_FINISH {
            self.instrument?.stopPing(trackerId: tracker.trackerId!)
            if tracker.getState().inAd {
                setInAdState(state: false)
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.END {
            // To avoid content end when an ad break happens
            if tracker.getState().inAdBreak {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.AD_PAUSE_BEGIN {
            if !tracker.getState().isPaused {
                tracker.getState().isPaused = true
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.AD_PAUSE_FINISH {
            if tracker.getState().isPaused {
                tracker.getState().isPaused = false
            }
            else {
                return nil
            }
        }
        
        event.setAttribute(key: OAVTAttribute.IN_AD_BREAK_BLOCK, value: tracker.getState().inAdBreak)
        event.setAttribute(key: OAVTAttribute.IN_AD_BLOCK, value: tracker.getState().inAd)
        event.setAttribute(key: OAVTAttribute.COUNT_ADS, value: countAds)
        
        // Get current content video position
        if let trackers = self.instrument?.getTrackers() {
            for (_, tracker) in trackers {
                if let isAdsTracker = self.instrument?.callGetter(attribute: OAVTAttribute.IS_ADS_TRACKER, tracker: tracker) as? Bool {
                    if !isAdsTracker {
                        instrument?.useGetter(attribute: OAVTAttribute.POSITION, event: event, tracker: tracker)
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

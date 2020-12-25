//
//  OAVTHubAds.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 04/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

open class OAVTHubCoreAds : OAVTHubCore {
    
    var instrument : OAVTInstrument?
    
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
            setInAdState(state: true)
        }
        else if event.getAction() == OAVTAction.AD_FINISH {
            if tracker.getState().inAd {
                setInAdState(state: false)
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.PAUSE_BEGIN || event.getAction() == OAVTAction.END {
            if tracker.getState().inAdBreak {
                return nil
            }
        }
        
        event.setAttribute(key: OAVTAttribute.IN_AD_BREAK_BLOCK, value: tracker.getState().inAdBreak)
        event.setAttribute(key: OAVTAttribute.IN_AD_BLOCK, value: tracker.getState().inAd)
        
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

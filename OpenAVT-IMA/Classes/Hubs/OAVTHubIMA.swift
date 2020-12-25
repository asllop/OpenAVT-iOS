//
//  OAVTHubIMA.swift
//  OpenAVT-IMA
//
//  Created by Andreu Santaren on 04/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation
import OpenAVT_Core

open class OAVTHubIMA : OAVTHubCore {
    
    open override func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent? {
        if event.getAction() == OAVTAction.AD_BREAK_BEGIN {
            tracker.getState().inAdBreak = true
        }
        else if event.getAction() == OAVTAction.AD_BREAK_FINISH {
            if tracker.getState().inAdBreak {
                tracker.getState().inAdBreak = false
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.AD_BEGIN {
            tracker.getState().inAd = true
        }
        else if event.getAction() == OAVTAction.AD_FINISH {
            if tracker.getState().inAd {
                tracker.getState().inAd = false
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
        
        return super.processEvent(event: event, tracker: tracker)
    }
}

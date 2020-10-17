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
            state.inAdBreak = true
        }
        else if event.getAction() == OAVTAction.AD_BREAK_FINISH {
            if state.inAdBreak {
                state.inAdBreak = false
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.AD_BEGIN {
            state.inAd = true
        }
        else if event.getAction() == OAVTAction.AD_FINISH {
            if state.inAd {
                state.inAd = false
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.PAUSE_BEGIN || event.getAction() == OAVTAction.END {
            if state.inAdBreak {
                return nil
            }
        }
        
        event.setAttribute(key: OAVTAttribute.IN_AD_BREAK_BLOCK, value: state.inAdBreak)
        event.setAttribute(key: OAVTAttribute.IN_AD_BLOCK, value: state.inAd)
        
        return super.processEvent(event: event, tracker: tracker)
    }
}

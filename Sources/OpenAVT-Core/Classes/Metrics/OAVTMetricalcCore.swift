//
//  OAVTMetricalcCore.swift
//  OpenAVT-Core
//
//  Created by asllop on 19/12/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OAVT metricalc for generic player metric calculations.
open class OAVTMetricalcCore : OAVTMetricalcProtocol {
    
    public init() {
    }
    
    public func processMetric(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> [OAVTMetric] {
        var metricArray : [OAVTMetric] = []
        
        if event.getAction() == OAVTAction.START {
            if let timeSinceMediaRequest = event.getAttribute(key: OAVTAction.MEDIA_REQUEST.getTimeAttribute()) as? Int {
                metricArray.append(OAVTMetric.START_TIME(timeSinceMediaRequest))
            }
            else if let timeSinceStreamLoad = event.getAttribute(key: OAVTAction.STREAM_LOAD.getTimeAttribute()) as? Int {
                metricArray.append(OAVTMetric.START_TIME(timeSinceStreamLoad))
            }
            metricArray.append(OAVTMetric.NUM_PLAYS(1))
        }
        else if event.getAction() == OAVTAction.BUFFER_FINISH {
            if let inPlaybackBlock = event.getAttribute(key: OAVTAttribute.IN_PLAYBACK_BLOCK) as? Bool {
                if let inPauseBlock = event.getAttribute(key: OAVTAttribute.IN_PAUSE_BLOCK) as? Bool {
                    if let inSeekBlock = event.getAttribute(key: OAVTAttribute.IN_SEEK_BLOCK) as? Bool {
                        if (inPlaybackBlock && !inPauseBlock && !inSeekBlock) {
                            if let timeSinceBufferBegin = event.getAttribute(key: OAVTAction.BUFFER_BEGIN.getTimeAttribute()) as? Int {
                                metricArray.append(OAVTMetric.REBUFFER_TIME(timeSinceBufferBegin))
                                metricArray.append(OAVTMetric.NUM_REBUFFERS(1))
                            }
                        }
                    }
                }
            }
        }
        else if event.getAction() == OAVTAction.MEDIA_REQUEST {
            metricArray.append(OAVTMetric.NUM_REQUESTS(1))
        }
        else if event.getAction() == OAVTAction.STREAM_LOAD {
            metricArray.append(OAVTMetric.NUM_LOADS(1))
        }
        else if event.getAction() == OAVTAction.END || event.getAction() == OAVTAction.STOP || event.getAction() == OAVTAction.NEXT  {
            metricArray.append(OAVTMetric.NUM_ENDS(1))
        }
        
        if let deltaPlayTime = event.getAttribute(key: OAVTAttribute.DELTA_PLAY_TIME) as? Int {
            metricArray.append(OAVTMetric.PLAY_TIME(deltaPlayTime))
        }
        
        return metricArray
    }
    
    public func instrumentReady(instrument: OAVTInstrument) {
    }
    
    public func endOfService() {
    }
}

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
                metricArray.append(OAVTMetric(name: OAVTMetric.START_TIME, type: OAVTMetric.MetricType.Gauge, value: timeSinceMediaRequest))
            }
            else if let timeSinceStreamLoad = event.getAttribute(key: OAVTAction.STREAM_LOAD.getTimeAttribute()) as? Int {
                metricArray.append(OAVTMetric(name: OAVTMetric.START_TIME, type: OAVTMetric.MetricType.Gauge, value: timeSinceStreamLoad))
            }
            metricArray.append(OAVTMetric(name: OAVTMetric.NUM_PLAYS, type: OAVTMetric.MetricType.Counter, value: 1))
        }
        else if event.getAction() == OAVTAction.BUFFER_FINISH {
            if let inPlaybackBlock = event.getAttribute(key: OAVTAttribute.IN_PLAYBACK_BLOCK) as? Bool {
                if let inPauseBlock = event.getAttribute(key: OAVTAttribute.IN_PAUSE_BLOCK) as? Bool {
                    if let inSeekBlock = event.getAttribute(key: OAVTAttribute.IN_SEEK_BLOCK) as? Bool {
                        if (inPlaybackBlock && !inPauseBlock && !inSeekBlock) {
                            if let timeSinceBufferBegin = event.getAttribute(key: OAVTAction.BUFFER_BEGIN.getTimeAttribute()) as? Int {
                                metricArray.append(OAVTMetric(name: OAVTMetric.REBUFFER_TIME, type: OAVTMetric.MetricType.Counter, value: timeSinceBufferBegin))
                                metricArray.append(OAVTMetric(name: OAVTMetric.NUM_REBUFFERS, type: OAVTMetric.MetricType.Counter, value: 1))
                            }
                        }
                    }
                }
            }
        }
        else if event.getAction() == OAVTAction.MEDIA_REQUEST {
            metricArray.append(OAVTMetric(name: OAVTMetric.NUM_REQUESTS, type: OAVTMetric.MetricType.Counter, value: 1))
        }
        else if event.getAction() == OAVTAction.STREAM_LOAD {
            metricArray.append(OAVTMetric(name: OAVTMetric.NUM_LOADS, type: OAVTMetric.MetricType.Counter, value: 1))
        }
        else if event.getAction() == OAVTAction.END || event.getAction() == OAVTAction.STOP || event.getAction() == OAVTAction.NEXT  {
            metricArray.append(OAVTMetric(name: OAVTMetric.NUM_ENDS, type: OAVTMetric.MetricType.Counter, value: 1))
        }
        
        if let deltaPlayTime = event.getAttribute(key: OAVTAttribute.DELTA_PLAY_TIME) as? Int {
            metricArray.append(OAVTMetric(name: OAVTMetric.PLAY_TIME, type: OAVTMetric.MetricType.Counter, value: deltaPlayTime))
        }
        
        return metricArray
    }
    
    public func instrumentReady(instrument: OAVTInstrument) {
    }
    
    public func endOfService() {
    }
}

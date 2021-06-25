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
        
        if event.getAction() == OAVTAction.Start {
            if let timeSinceMediaRequest = event.getAttribute(key: OAVTAction.MediaRequest.getTimeAttribute()) as? Int {
                metricArray.append(OAVTMetric.StartTime(timeSinceMediaRequest))
            }
            else if let timeSinceStreamLoad = event.getAttribute(key: OAVTAction.StreamLoad.getTimeAttribute()) as? Int {
                metricArray.append(OAVTMetric.StartTime(timeSinceStreamLoad))
            }
            metricArray.append(OAVTMetric.NumPlays(1))
        }
        else if event.getAction() == OAVTAction.BufferFinish {
            if let inPlaybackBlock = event.getAttribute(key: OAVTAttribute.inPlaybackBlock) as? Bool {
                if let inPauseBlock = event.getAttribute(key: OAVTAttribute.inPauseBlock) as? Bool {
                    if let inSeekBlock = event.getAttribute(key: OAVTAttribute.inSeekBlock) as? Bool {
                        if (inPlaybackBlock && !inPauseBlock && !inSeekBlock) {
                            if let timeSinceBufferBegin = event.getAttribute(key: OAVTAction.BufferBegin.getTimeAttribute()) as? Int {
                                metricArray.append(OAVTMetric.RebufferTime(timeSinceBufferBegin))
                                metricArray.append(OAVTMetric.NumRebuffers(1))
                            }
                        }
                    }
                }
            }
        }
        else if event.getAction() == OAVTAction.MediaRequest {
            metricArray.append(OAVTMetric.NumRequests(1))
        }
        else if event.getAction() == OAVTAction.StreamLoad {
            metricArray.append(OAVTMetric.NumLoads(1))
        }
        else if event.getAction() == OAVTAction.End || event.getAction() == OAVTAction.Stop || event.getAction() == OAVTAction.Next  {
            metricArray.append(OAVTMetric.NumEnds(1))
        }
        
        if let deltaPlayTime = event.getAttribute(key: OAVTAttribute.deltaPlayTime) as? Int {
            metricArray.append(OAVTMetric.PlayTime(deltaPlayTime))
        }
        
        return metricArray
    }
    
    public func instrumentReady(instrument: OAVTInstrument) {
    }
    
    public func endOfService() {
    }
}

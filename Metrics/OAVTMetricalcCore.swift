//
//  OAVTMetricalcCore.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 19/12/2020.
//

import Foundation

open class OAVTMetricalcCore : OAVTMetricalcProtocol {
    
    public init() {
    }
    
    //TODO: calculate most common KPIs
    //- Playtime since last event -> MetricType.Counter
    //- Rebuffering time -> MetricType.Counter
    //- Number of rebuffers -> MetricType.Counter
    //- Num errors before start -> MetricType.Counter
    //- Total Playtime on END/STOP/NEXT -> MetricType.Gauge
    
    //TODO: problem, what if we wanna calculate multiple metrics in the same processMetric call?
    
    public func processMetric(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTMetric? {
        if (event.getAction() == OAVTAction.START) {
            if let timeSinceMediaRequest = event.getAttribute(key: OAVTAction.MEDIA_REQUEST.getTimeAttribute()) {
                return OAVTMetric(name: "startTime", type: OAVTMetric.MetricType.Gauge, value: timeSinceMediaRequest as! Int)
            }
            else if let timeSinceStreamLoad = event.getAttribute(key: OAVTAction.STREAM_LOAD.getTimeAttribute()) {
                return OAVTMetric(name: "startTime", type: OAVTMetric.MetricType.Gauge, value: timeSinceStreamLoad as! Int)
            }
        }
        else if (event.getAction() == OAVTAction.STREAM_LOAD) {
            return OAVTMetric(name: "numVideos", type: OAVTMetric.MetricType.Counter, value: 1)
        }
        
        return nil
    }
    
    public func instrumentReady(instrument: OAVTInstrument) {
    }
    
    public func endOfService() {
    }
}

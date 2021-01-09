//
//  OAVTBackendProtocol.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT protocol for Backend objects.
public protocol OAVTBackendProtocol: OAVTComponentProtocol {
    
    /**
     Send an event.
     
     - Parameters:
        - event: Event received.
    */
    func sendEvent(event: OAVTEvent)
    
    /**
     Send a metric.
     
     - Parameters:
        - metric: Metric received.
    */
    func sendMetric(metric: OAVTMetric)
}

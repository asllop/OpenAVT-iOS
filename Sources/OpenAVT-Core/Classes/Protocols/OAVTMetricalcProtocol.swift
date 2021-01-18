//
//  OAVTMetricalcProtocol.swift
//  OpenAVT-Core
//
//  Created by asllop on 19/12/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT protocol for Metric Calculator objects.
public protocol OAVTMetricalcProtocol: OAVTComponentProtocol {
    /**
     Process metrics.
     
     - Parameters:
        - event: Event received.
        - tracker: Tracker that generated the event.
     
     - Returns: Array of metrics.
    */
    func processMetric(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> [OAVTMetric]
}

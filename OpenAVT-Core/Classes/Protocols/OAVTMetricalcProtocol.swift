//
//  OAVTMetricalcProtocol.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 19/12/2020.
//

import Foundation

/// OpenAVT protocol for Metric Calculator objects.
public protocol OAVTMetricalcProtocol: OAVTComponentProtocol {
    /**
     Process metrics.
     
     - Parameters:
        - event: Event received.
        - tracker: Tracker that generated the event.
     
     - Returns: The metric or nil.
    */
    func processMetric(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTMetric?
}

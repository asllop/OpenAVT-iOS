//
//  OAVTHubProtocol.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT protocol for Hub objects.
public protocol OAVTHubProtocol: OAVTBaseProtocol {
    /**
     Process an event.
     
     - Parameters:
        - event: Event received.
        - tracker: Tracker that generated the event.
     
     - Returns: The event or nil.
    */
    func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent?
    /**
     Returns the current state.
     
     - Returns: The state.
    */
    func getState() -> OAVTState
}

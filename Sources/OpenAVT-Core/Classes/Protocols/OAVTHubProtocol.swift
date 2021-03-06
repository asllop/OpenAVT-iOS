//
//  OAVTHubProtocol.swift
//  OpenAVT-Core
//
//  Created by asllop on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT protocol for Hub objects.
public protocol OAVTHubProtocol: OAVTComponentProtocol {
    /**
     Process an event.
     
     - Parameters:
        - event: Event received.
        - tracker: Tracker that generated the event.
     
     - Returns: The event or nil.
    */
    func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent?
}

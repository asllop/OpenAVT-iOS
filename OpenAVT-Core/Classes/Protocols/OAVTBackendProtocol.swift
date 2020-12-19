//
//  OAVTBackendProtocol.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT protocol for Backend objects.
public protocol OAVTBackendProtocol: OAVTComponentProtocol {
    /**
     Receive an event.
     
     - Parameters:
        - event: Event received.
        - tracker: Tracker that generated the event.
     
     - Returns: The event or nil.
    */
    func receiveEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent?
    /**
     Send an event.
     
     - Parameters:
        - event: Event received.
    */
    func sendEvent(event: OAVTEvent)
}

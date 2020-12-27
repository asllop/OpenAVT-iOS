//
//  OAVTTrackerProtocol.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT protocol for Tracker objects.
public protocol OAVTTrackerProtocol: OAVTComponentProtocol {
    /**
     Init an event.
     
     - Parameters:
        - event: Event received.
     
     - Returns: The event or nil.
    */
    func initEvent(event: OAVTEvent) -> OAVTEvent?
    /**
     Returns the current state.
     
     - Returns: The state.
    */
    func getState() -> OAVTState
    /// Tracker ID.
    var trackerId : Int? { get set }
}

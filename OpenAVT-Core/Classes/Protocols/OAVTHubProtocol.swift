//
//  OAVTHubProtocol.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

public protocol OAVTHubProtocol: OAVTBaseProtocol {
    func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent?
    func getState() -> OAVTState
}

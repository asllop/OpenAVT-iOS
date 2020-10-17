//
//  OAVTBackendProtocol.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

public protocol OAVTBackendProtocol: OAVTBaseProtocol {
    func receiveEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent?
    func sendEvent(event: OAVTEvent)
}

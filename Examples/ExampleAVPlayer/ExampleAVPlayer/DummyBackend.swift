//
//  FakeBackend.swift
//  ExamplePlayer
//
//  Created by Andreu Santaren on 27/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation
import OpenAVT_Core

class DummyBackend : OAVTBackendProtocol {
    
    deinit {
        OAVTLog.verbose("##### DummyBackend deinit")
    }
    
    func receiveEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent? {
        return event
    }
    
    func sendEvent(event: OAVTEvent) {
        OAVTLog.verbose("---> SEND EVENT = \(event.description)")
    }
    
    func instrumentReady(instrument: OAVTInstrument) {
    }
    
    func endOfService() {
    }
}

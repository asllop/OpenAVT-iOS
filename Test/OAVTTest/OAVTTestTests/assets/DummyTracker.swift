//
//  DummyTracker.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 17/8/21.
//

import Foundation
import OpenAVT_Core

class DummyTracker: OAVTTrackerProtocol {
    private let state = OAVTState()
    
    func initEvent(event: OAVTEvent) -> OAVTEvent? {
        return event
    }
    
    func getState() -> OAVTState {
        return state
    }
    
    var trackerId: Int?
    
    func instrumentReady(instrument: OAVTInstrument) {
        
    }
    
    func endOfService() {
        
    }
}

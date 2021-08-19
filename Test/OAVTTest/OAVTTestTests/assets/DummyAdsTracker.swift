//
//  DummyAdsTracker.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 19/8/21.
//

import Foundation
import OpenAVT_Core

class DummyAdsTracker: OAVTTrackerProtocol {
    private let state = OAVTState()
    
    func initEvent(event: OAVTEvent) -> OAVTEvent? {
        return event
    }
    
    func getState() -> OAVTState {
        return state
    }
    
    var trackerId: Int?
    
    func instrumentReady(instrument: OAVTInstrument) {
        instrument.registerGetter(attribute: OAVTAttribute.isAdsTracker, getter: self.getIsAdsTracker, tracker: self)
    }
    
    func endOfService() {}
    
    func getIsAdsTracker() -> Bool {
        return true
    }
}

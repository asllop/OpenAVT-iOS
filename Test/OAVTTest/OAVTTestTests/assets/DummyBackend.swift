//
//  DummyBackend.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 17/8/21.
//

import Foundation
import OpenAVT_Core

class DummyBackend: OAVTBackendProtocol {
    func sendEvent(event: OAVTEvent) {
        
    }
    
    func sendMetric(metric: OAVTMetric) {
        
    }
    
    func instrumentReady(instrument: OAVTInstrument) {
        
    }
    
    func endOfService() {
        
    }
}

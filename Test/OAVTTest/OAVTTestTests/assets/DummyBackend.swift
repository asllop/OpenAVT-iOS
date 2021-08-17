//
//  DummyBackend.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 17/8/21.
//

import Foundation
import OpenAVT_Core

class DummyBackend: OAVTBackendProtocol {
    private var latestEvent: OAVTEvent? = nil
    private var latestMetrics: [OAVTMetric] = []
    
    func sendEvent(event: OAVTEvent) {
        latestEvent = event
    }
    
    func sendMetric(metric: OAVTMetric) {
        latestMetrics.append(metric)
    }
    
    func instrumentReady(instrument: OAVTInstrument) {}
    
    func endOfService() {}
    
    public func getLastEvent() -> OAVTEvent? {
        let ev = latestEvent
        latestEvent = nil
        return ev
    }

    public func getLastMetric() -> OAVTMetric? {
        return latestMetrics.popLast()
    }

    public func clearMetrics() {
        latestMetrics.removeAll()
    }
}

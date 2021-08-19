//
//  MetricsTests.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 19/8/21.
//

import XCTest
import OpenAVT_Core

class MetricsTests: XCTestCase {
    
    func testMetricsWorkflow() {
        let (instrument, trackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId)
        var metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "NumRequests")
        XCTAssertEqual(metric.getNSValue(), 1)

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "NumLoads")
        XCTAssertEqual(metric.getNSValue(), 1)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        XCTAssertNil(backend.getLastMetric())

        Thread.sleep(forTimeInterval: 0.7)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "NumPlays")
        XCTAssertEqual(metric.getNSValue(), 1)
        metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "StartTime")
        XCTAssertEqual(metric.getNSValue() as! Int, 700, accuracy: 50)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)

        // Remove PlayTime metrics
        backend.clearMetrics()

        Thread.sleep(forTimeInterval: 0.5)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "NumRebuffers")
        XCTAssertEqual(metric.getNSValue(), 1)
        metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "RebufferTime")
        XCTAssertEqual(metric.getNSValue() as! Int, 500, accuracy: 50)

        Thread.sleep(forTimeInterval: 0.8)

        instrument.emit(action: OAVTAction.Error, trackerId: trackerId)
        metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "PlayTime")
        XCTAssertEqual(metric.getNSValue() as! Int, 800, accuracy: 50)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "PlayTime")
        metric = backend.getLastMetric()!
        XCTAssertEqual(metric.getName(), "NumEnds")
        XCTAssertEqual(metric.getNSValue(), 1)
    }

    private func createInstrument() -> (OAVTInstrument, Int) {
        let instrument = OAVTInstrument(hub: OAVTHubCore(), metricalc: OAVTMetricalcCore(), backend: DummyBackend())
        let trackerId = instrument.addTracker(DummyTracker())
        instrument.ready()
        return (instrument, trackerId)
    }
}

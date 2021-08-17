//
//  CoreTests.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 16/8/21.
//

import XCTest
import OpenAVT_Core
@testable import OAVTTest

class CoreTests: XCTestCase {

    func testTrackedIdIntegrity() throws {
       let (instrument, trackerId) = createInstrument()
        XCTAssertEqual(trackerId, instrument.getTracker(trackerId)!.trackerId)
    }

    private func createInstrument() -> (OAVTInstrument, Int) {
        let instrument = OAVTInstrument(hub: OAVTHubCore(), backend: DummyBackend())
        let trackerId = instrument.addTracker(DummyTracker())
        instrument.ready()
        return (instrument, trackerId)
    }
}

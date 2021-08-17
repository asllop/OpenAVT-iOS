//
//  OAVTAssert.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 17/8/21.
//

import XCTest
import OpenAVT_Core

public func AssertStates(_ tracker: OAVTTrackerProtocol, _ compareState: OAVTState) {
    XCTAssertEqual(tracker.getState().didMediaRequest, compareState.didMediaRequest)
    XCTAssertEqual(tracker.getState().didPlayerSet, compareState.didPlayerSet)
    XCTAssertEqual(tracker.getState().didStreamLoad, compareState.didStreamLoad)
    XCTAssertEqual(tracker.getState().didStart, compareState.didStart)
    XCTAssertEqual(tracker.getState().isBuffering, compareState.isBuffering)
    XCTAssertEqual(tracker.getState().isPaused, compareState.isPaused)
    XCTAssertEqual(tracker.getState().isSeeking, compareState.isSeeking)
    XCTAssertEqual(tracker.getState().didFinish, compareState.didFinish)
    XCTAssertEqual(tracker.getState().inAdBreak, compareState.inAdBreak)
    XCTAssertEqual(tracker.getState().inAd, compareState.inAd)
}

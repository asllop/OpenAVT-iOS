//
//  AdsTests.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 19/8/21.
//

import XCTest
import OpenAVT_Core

class AdsTests: XCTestCase {
    
    func testTrackedIdIntegrity() throws {
       let (instrument, trackerId, adTrackerId) = createInstrument()
        XCTAssertEqual(trackerId, instrument.getTracker(trackerId)!.trackerId)
        XCTAssertEqual(adTrackerId, instrument.getTracker(adTrackerId)!.trackerId)
    }
    
    func testAdsState() {
        let (instrument, trackerId, adTrackerId) = createInstrument()
        let tracker = instrument.getTracker(trackerId)!
        let adTracker = instrument.getTracker(adTrackerId)!
        let compareState = OAVTState()
        let compareAdState = OAVTState()

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId)
        compareState.didMediaRequest = true

        instrument.emit(action: OAVTAction.PlayerSet, trackerId: trackerId)
        compareState.didPlayerSet = true

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        compareState.didStreamLoad = true

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        compareState.isBuffering = true

        // Pre-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        compareState.inAdBreak = true
        compareAdState.inAdBreak = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        compareState.inAd = true
        compareAdState.inAd = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        compareState.inAd = false
        compareAdState.inAd = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        compareState.inAdBreak = false
        compareAdState.inAdBreak = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        compareState.isBuffering = false

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        compareState.didStart = true

        // Mid-roll ad break (2 ads)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        compareState.inAdBreak = true
        compareAdState.inAdBreak = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        compareState.inAd = true
        compareAdState.inAd = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        compareState.inAd = false
        compareAdState.inAd = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        compareState.inAd = true
        compareAdState.inAd = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        compareState.inAd = false
        compareAdState.inAd = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        compareState.inAdBreak = false
        compareAdState.inAdBreak = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        compareState.didFinish = true

        // Post-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        compareState.inAdBreak = true
        compareAdState.inAdBreak = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        compareState.inAd = true
        compareAdState.inAd = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        compareState.inAd = false
        compareAdState.inAd = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        compareState.inAdBreak = false
        compareAdState.inAdBreak = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)
    }

    func testAdEventWorkflow() {
        let (instrument, trackerId, adTrackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)

        // Pre-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakBegin)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBegin)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdFinish)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakFinish)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)

        // Mid-roll ad break (2 ads)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakBegin)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBegin)

        instrument.emit(action: OAVTAction.AdPauseBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdPauseBegin)

        instrument.emit(action: OAVTAction.AdPauseFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdPauseFinish)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdFinish)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBegin)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdFinish)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakFinish)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)

        // Post-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakBegin)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBegin)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdFinish)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakFinish)
    }
    
    func testAdStateMistakes() {
        let (instrument, trackerId, adTrackerId) = createInstrument()
        let tracker = instrument.getTracker(trackerId)!
        let adTracker = instrument.getTracker(adTrackerId)!
        let compareState = OAVTState()
        let compareAdState = OAVTState()

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId)
        compareState.didMediaRequest = true

        instrument.emit(action: OAVTAction.PlayerSet, trackerId: trackerId)
        compareState.didPlayerSet = true

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        compareState.didStreamLoad = true

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        compareState.isBuffering = true

        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        // Pre-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId) // Repeated event
        compareState.inAdBreak = true
        compareAdState.inAdBreak = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        compareState.inAd = true
        compareAdState.inAd = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId) // Repeated event
        compareState.inAd = false
        compareAdState.inAd = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        compareState.inAdBreak = false
        compareAdState.inAdBreak = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        compareState.isBuffering = false

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        compareState.didStart = true

        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        // Mid-roll ad break (2 ads)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        compareState.inAdBreak = true
        compareAdState.inAdBreak = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        compareState.inAd = true
        compareAdState.inAd = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        compareState.inAd = false
        compareAdState.inAd = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        compareState.inAd = true
        compareAdState.inAd = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        compareState.inAd = false
        compareAdState.inAd = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        compareState.inAdBreak = false
        compareAdState.inAdBreak = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        compareState.didFinish = true

        // Post-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        compareState.inAdBreak = true
        compareAdState.inAdBreak = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        compareState.inAd = true
        compareAdState.inAd = true
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)

        // missing ad end
        // Note: Ad trackers should call AdFinish before AdBreakFinish to avoid keeping inAd state true.

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        compareState.inAdBreak = false
        compareAdState.inAdBreak = false
        AssertStates(tracker, compareState)
        AssertStates(adTracker, compareAdState)
    }
    
    func testAdEventWorkflowMistake() {
        let (instrument, trackerId, adTrackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)

        // Pre-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakBegin)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBegin)

        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId) // Event at wrong position
        XCTAssertNil(backend.getLastEvent())

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdFinish)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId) // Repeated event
        XCTAssertNil(backend.getLastEvent())

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakFinish)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)

        // Mid-roll ad break (2 ads)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakBegin)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBegin)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdFinish)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBegin)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdFinish)

        // Ad Pause block outside of an Ad block
        instrument.emit(action: OAVTAction.AdPauseBegin, trackerId: adTrackerId)
        XCTAssertNil(backend.getLastEvent())
        instrument.emit(action: OAVTAction.AdPauseFinish, trackerId: adTrackerId)
        XCTAssertNil(backend.getLastEvent())

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakFinish)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId) // Repeated event
        XCTAssertNil(backend.getLastEvent())

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        let _ = backend.getLastEvent()

        // Post-roll ad break (1 ad)

        // Missing AdBreakBegin
        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        XCTAssertNil(backend.getLastEvent())
        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        XCTAssertNil(backend.getLastEvent())
        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        XCTAssertNil(backend.getLastEvent())
    }
    
    func testAdTimeSinceAttributes() {
        let (instrument, trackerId, adTrackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)

        // Pre-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdBreakBegin)

        Thread.sleep(forTimeInterval: 0.5)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        let adBeginEvent = backend.getLastEvent()!
        XCTAssertEqual(adBeginEvent.getAction(), OAVTAction.AdBegin)
        XCTAssertEqual(adBeginEvent.getAttribute(key: OAVTAction.AdBreakBegin.getTimeAttribute()) as! Int, 500, accuracy: 50)

        Thread.sleep(forTimeInterval: 1.0)

        instrument.emit(action: OAVTAction.AdPauseBegin, trackerId: adTrackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.AdPauseBegin)

        Thread.sleep(forTimeInterval: 0.6)

        instrument.emit(action: OAVTAction.AdPauseFinish, trackerId: adTrackerId)
        let adPauseEvent = backend.getLastEvent()!
        XCTAssertEqual(adPauseEvent.getAction(), OAVTAction.AdPauseFinish)
        XCTAssertEqual(adPauseEvent.getAttribute(key: OAVTAction.AdPauseBegin.getTimeAttribute()) as! Int, 600, accuracy: 50)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        let adFinishEvent = backend.getLastEvent()!
        XCTAssertEqual(adFinishEvent.getAction(), OAVTAction.AdFinish)
        XCTAssertEqual(adFinishEvent.getAttribute(key: OAVTAction.AdBegin.getTimeAttribute()) as! Int, 1600, accuracy: 50)

        Thread.sleep(forTimeInterval: 0.3)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        let adBreakFinishEvent = backend.getLastEvent()!
        XCTAssertEqual(adBreakFinishEvent.getAction(), OAVTAction.AdBreakFinish)
        XCTAssertEqual(adBreakFinishEvent.getAttribute(key: OAVTAction.AdBreakBegin.getTimeAttribute()) as! Int, 2400, accuracy: 50)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
    }
    
    func testAdCounters() {
        let (instrument, trackerId, adTrackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        let sloadEvent = backend.getLastEvent()!
        XCTAssertEqual(sloadEvent.getAction(), OAVTAction.StreamLoad)
        XCTAssertEqual(sloadEvent.getAttribute(key: OAVTAttribute.countAds) as! Int, 0)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)

        // Pre-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        let adBreakFinish1 = backend.getLastEvent()!
        XCTAssertEqual(adBreakFinish1.getAction(), OAVTAction.AdBreakFinish)
        XCTAssertEqual(adBreakFinish1.getAttribute(key: OAVTAttribute.countAds) as! Int, 1)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)

        // Mid-roll ad break (2 ads)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdPauseBegin, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdPauseFinish, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        let adBreakFinish2 = backend.getLastEvent()!
        XCTAssertEqual(adBreakFinish2.getAction(), OAVTAction.AdBreakFinish)
        XCTAssertEqual(adBreakFinish2.getAttribute(key: OAVTAttribute.countAds) as! Int, 3)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)

        // Post-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        let adBreakFinish3 = backend.getLastEvent()!
        XCTAssertEqual(adBreakFinish3.getAction(), OAVTAction.AdBreakFinish)
        XCTAssertEqual(adBreakFinish3.getAttribute(key: OAVTAttribute.countAds) as! Int, 4)
    }
    
    func testInBlocks() {
        let (instrument, trackerId, adTrackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        let sloadEvent = backend.getLastEvent()!
        XCTAssertEqual(sloadEvent.getAction(), OAVTAction.StreamLoad)
        XCTAssertFalse(sloadEvent.getAttribute(key: OAVTAttribute.inAdBreakBlock) as! Bool)
        XCTAssertFalse(sloadEvent.getAttribute(key: OAVTAttribute.inAdBlock) as! Bool)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)

        // Pre-roll ad break (1 ad)
        instrument.emit(action: OAVTAction.AdBreakBegin, trackerId: adTrackerId)
        let adBreakBeginEvent1 = backend.getLastEvent()!
        XCTAssertEqual(adBreakBeginEvent1.getAction(), OAVTAction.AdBreakBegin)
        XCTAssertTrue(adBreakBeginEvent1.getAttribute(key: OAVTAttribute.inAdBreakBlock) as! Bool)
        XCTAssertFalse(adBreakBeginEvent1.getAttribute(key: OAVTAttribute.inAdBlock) as! Bool)

        instrument.emit(action: OAVTAction.AdBegin, trackerId: adTrackerId)
        let adBeginEvent1 = backend.getLastEvent()!
        XCTAssertEqual(adBeginEvent1.getAction(), OAVTAction.AdBegin)
        XCTAssertTrue(adBeginEvent1.getAttribute(key: OAVTAttribute.inAdBreakBlock) as! Bool)
        XCTAssertTrue(adBeginEvent1.getAttribute(key: OAVTAttribute.inAdBlock) as! Bool)

        instrument.emit(action: OAVTAction.AdFinish, trackerId: adTrackerId)
        let adFinishEvent1 = backend.getLastEvent()!
        XCTAssertEqual(adFinishEvent1.getAction(), OAVTAction.AdFinish)
        XCTAssertTrue(adFinishEvent1.getAttribute(key: OAVTAttribute.inAdBreakBlock) as! Bool)
        XCTAssertFalse(adFinishEvent1.getAttribute(key: OAVTAttribute.inAdBlock) as! Bool)

        instrument.emit(action: OAVTAction.AdBreakFinish, trackerId: adTrackerId)
        let adBreakFinishEvent1 = backend.getLastEvent()!
        XCTAssertEqual(adBreakFinishEvent1.getAction(), OAVTAction.AdBreakFinish)
        XCTAssertFalse(adBreakFinishEvent1.getAttribute(key: OAVTAttribute.inAdBreakBlock) as! Bool)
        XCTAssertFalse(adBreakFinishEvent1.getAttribute(key: OAVTAttribute.inAdBlock) as! Bool)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
    }
    
    private func createInstrument() -> (OAVTInstrument, Int, Int) {
        let instrument = OAVTInstrument(hub: OAVTHubCoreAds(), backend: DummyBackend())
        let trackerId = instrument.addTracker(DummyTracker())
        let adTrackerId = instrument.addTracker(DummyAdsTracker())
        instrument.ready()
        return (instrument, trackerId, adTrackerId)
    }
}

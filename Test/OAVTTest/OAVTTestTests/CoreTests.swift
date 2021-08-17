//
//  CoreTests.swift
//  OAVTTestTests
//
//  Created by Andreu Santaren on 16/8/21.
//

import XCTest
import OpenAVT_Core

class CoreTests: XCTestCase {

    func testTrackedIdIntegrity() throws {
       let (instrument, trackerId) = createInstrument()
        XCTAssertEqual(trackerId, instrument.getTracker(trackerId)!.trackerId)
    }
    
    func testPlayerState() {
        let (instrument, trackerId) = createInstrument()
        let tracker = instrument.getTracker(trackerId)!
        let compareState = OAVTState()

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId)
        compareState.didMediaRequest = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.PlayerSet, trackerId: trackerId)
        compareState.didPlayerSet = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        compareState.didStreamLoad = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        compareState.isBuffering = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        compareState.isBuffering = false
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        compareState.didStart = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        compareState.isPaused = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.SeekBegin, trackerId: trackerId)
        compareState.isSeeking = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        compareState.isBuffering = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        compareState.isBuffering = false
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.SeekFinish, trackerId: trackerId)
        compareState.isSeeking = false
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)
        compareState.isPaused = false
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        compareState.didFinish = true
        AssertStates(tracker, compareState)
    }

    func testEventWorkflow() {
        let (instrument, trackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.MediaRequest)

        instrument.emit(action: OAVTAction.PlayerSet, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.PlayerSet)

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.StreamLoad)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferBegin)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferFinish)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.Start)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.PauseBegin)

        instrument.emit(action: OAVTAction.SeekBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.SeekBegin)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferBegin)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferFinish)

        instrument.emit(action: OAVTAction.Error, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.Error)

        instrument.emit(action: OAVTAction.SeekFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.SeekFinish)

        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.PauseFinish)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.End)
    }
    
    func testPlayerStateMistakes() {
        let (instrument, trackerId) = createInstrument()
        let tracker = instrument.getTracker(trackerId)!
        let compareState = OAVTState()

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId)
        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId) // Repeated event
        compareState.didMediaRequest = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.PlayerSet, trackerId: trackerId)
        compareState.didPlayerSet = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        compareState.didStreamLoad = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId) // Repeated event
        compareState.isBuffering = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        compareState.isBuffering = false
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        compareState.didStart = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        compareState.isPaused = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.SeekBegin, trackerId: trackerId)
        compareState.isSeeking = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        compareState.isBuffering = true
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        compareState.isBuffering = false
        AssertStates(tracker, compareState)

        // Missing SeekFinish
        instrument.emit(action: OAVTAction.Ping, trackerId: trackerId)
        AssertStates(tracker, compareState)

        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)
        compareState.isPaused = false
        AssertStates(tracker, compareState)

        // Missing End
        instrument.emit(action: OAVTAction.Ping, trackerId: trackerId)
        AssertStates(tracker, compareState)
    }

    func testEventWorkflowMistakes() {
        let (instrument, trackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.Stop, trackerId: trackerId) // Event at wrong position
        XCTAssertNil(backend.getLastEvent())

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.MediaRequest)

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId) // Repeated event
        XCTAssertNil(backend.getLastEvent())

        instrument.emit(action: OAVTAction.PlayerSet, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.PlayerSet)

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.StreamLoad)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferBegin)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferFinish)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.Start)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.PauseBegin)

        instrument.emit(action: OAVTAction.SeekBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.SeekBegin)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferBegin)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferFinish)

        instrument.emit(action: OAVTAction.SeekFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.SeekFinish)

        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.PauseFinish)

        instrument.emit(action: OAVTAction.Ping, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.Ping)

        instrument.emit(action: OAVTAction.SeekFinish, trackerId: trackerId) // Finish block without begin
        XCTAssertNil(backend.getLastEvent())

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.End)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId) // End after an End
        XCTAssertNil(backend.getLastEvent())

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId) // Block after an End
        XCTAssertNil(backend.getLastEvent())
    }
    
    func testTimeSinceAttributes() {
        let (instrument, trackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.MediaRequest, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.MediaRequest)

        Thread.sleep(forTimeInterval: 0.3)

        instrument.emit(action: OAVTAction.PlayerSet, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.PlayerSet)

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.StreamLoad)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferBegin)

        Thread.sleep(forTimeInterval: 0.8)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        let bufferEvent1 = backend.getLastEvent()!
        XCTAssertEqual(bufferEvent1.getAction(), OAVTAction.BufferFinish)
        XCTAssertEqual(bufferEvent1.getAttribute(key: OAVTAction.BufferBegin.getTimeAttribute()) as! Int, 800, accuracy: 50)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        let startEvent1 = backend.getLastEvent()!
        XCTAssertEqual(startEvent1.getAction(), OAVTAction.Start)
        XCTAssertEqual(startEvent1.getAttribute(key: OAVTAction.MediaRequest.getTimeAttribute()) as! Int, 1100, accuracy: 50)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.PauseBegin)

        instrument.emit(action: OAVTAction.SeekBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.SeekBegin)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferBegin)

        Thread.sleep(forTimeInterval: 0.6)

        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.BufferFinish)

        instrument.emit(action: OAVTAction.SeekFinish, trackerId: trackerId)
        let seekEvent1 = backend.getLastEvent()!
        XCTAssertEqual(seekEvent1.getAction(), OAVTAction.SeekFinish)
        XCTAssertEqual(seekEvent1.getAttribute(key: OAVTAction.SeekBegin.getTimeAttribute()) as! Int, 600, accuracy: 50)

        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)
        let pauseEvent1 = backend.getLastEvent()!
        XCTAssertEqual(pauseEvent1.getAction(), OAVTAction.PauseFinish)
        XCTAssertEqual(pauseEvent1.getAttribute(key: OAVTAction.PauseBegin.getTimeAttribute()) as! Int, 600, accuracy: 50)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        XCTAssertEqual(backend.getLastEvent()!.getAction(), OAVTAction.End)
    }
    
    func testCounters() {
        let (instrument, trackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        let sloadEvent1 = backend.getLastEvent()!
        XCTAssertEqual(sloadEvent1.getAttribute(key: OAVTAttribute.countStarts) as! Int, 0)
        XCTAssertEqual(sloadEvent1.getAttribute(key: OAVTAttribute.countErrors) as! Int, 0)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        let startEvent1 = backend.getLastEvent()!
        XCTAssertEqual(startEvent1.getAttribute(key: OAVTAttribute.countStarts) as! Int, 1)
        XCTAssertEqual(startEvent1.getAttribute(key: OAVTAttribute.countErrors) as! Int, 0)

        instrument.emit(action: OAVTAction.Error, trackerId: trackerId)
        let errorEvent1 = backend.getLastEvent()!
        XCTAssertEqual(errorEvent1.getAttribute(key: OAVTAttribute.countStarts) as! Int, 1)
        XCTAssertEqual(errorEvent1.getAttribute(key: OAVTAttribute.countErrors) as! Int, 1)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        instrument.emit(action: OAVTAction.Ping, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Error, trackerId: trackerId)
        let errorEvent2 = backend.getLastEvent()!
        XCTAssertEqual(errorEvent2.getAttribute(key: OAVTAttribute.countStarts) as! Int, 1)
        XCTAssertEqual(errorEvent2.getAttribute(key: OAVTAttribute.countErrors) as! Int, 2)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        let startEvent2 = backend.getLastEvent()!
        XCTAssertEqual(startEvent2.getAttribute(key: OAVTAttribute.countStarts) as! Int, 2)
        XCTAssertEqual(startEvent2.getAttribute(key: OAVTAttribute.countErrors) as! Int, 2)

        instrument.emit(action: OAVTAction.Error, trackerId: trackerId)
        let errorEvent3 = backend.getLastEvent()!
        XCTAssertEqual(errorEvent3.getAttribute(key: OAVTAttribute.countStarts) as! Int, 2)
        XCTAssertEqual(errorEvent3.getAttribute(key: OAVTAttribute.countErrors) as! Int, 3)
    }

    func testAccumulatedTimes() {
        let (instrument, trackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        Thread.sleep(forTimeInterval: 0.8)
        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        Thread.sleep(forTimeInterval: 1.5)
        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        instrument.emit(action: OAVTAction.SeekBegin, trackerId: trackerId)
        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        Thread.sleep(forTimeInterval: 1.0)
        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        instrument.emit(action: OAVTAction.SeekFinish, trackerId: trackerId)
        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        let endEvent1 = backend.getLastEvent()!
        XCTAssertEqual(endEvent1.getAttribute(key: OAVTAttribute.accumBufferTime) as! Int, 1800, accuracy: 50)
        XCTAssertEqual(endEvent1.getAttribute(key: OAVTAttribute.accumPauseTime) as! Int, 2500, accuracy: 50)
        XCTAssertEqual(endEvent1.getAttribute(key: OAVTAttribute.accumSeekTime) as! Int, 1000, accuracy: 50)
    }
    
    func testInBlocks() {
        let (instrument, trackerId) = createInstrument()
        let backend: DummyBackend = instrument.getBackend() as! DummyBackend
        var event: OAVTEvent

        instrument.emit(action: OAVTAction.StreamLoad, trackerId: trackerId)
        event = backend.getLastEvent()!
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inPlaybackBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inPauseBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inBufferBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inSeekBlock) as! Bool)

        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        event = backend.getLastEvent()!
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inPlaybackBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inPauseBlock) as! Bool)
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inBufferBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inSeekBlock) as! Bool)
        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.Start, trackerId: trackerId)
        event = backend.getLastEvent()!
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inPlaybackBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inPauseBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inBufferBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inSeekBlock) as! Bool)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        event = backend.getLastEvent()!
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inPlaybackBlock) as! Bool)
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inPauseBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inBufferBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inSeekBlock) as! Bool)
        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)

        instrument.emit(action: OAVTAction.PauseBegin, trackerId: trackerId)
        instrument.emit(action: OAVTAction.SeekBegin, trackerId: trackerId)
        instrument.emit(action: OAVTAction.BufferBegin, trackerId: trackerId)
        event = backend.getLastEvent()!
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inPlaybackBlock) as! Bool)
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inPauseBlock) as! Bool)
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inBufferBlock) as! Bool)
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inSeekBlock) as! Bool)
        instrument.emit(action: OAVTAction.BufferFinish, trackerId: trackerId)
        instrument.emit(action: OAVTAction.SeekFinish, trackerId: trackerId)
        instrument.emit(action: OAVTAction.PauseFinish, trackerId: trackerId)
        event = backend.getLastEvent()!
        XCTAssertTrue(event.getAttribute(key: OAVTAttribute.inPlaybackBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inPauseBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inBufferBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inSeekBlock) as! Bool)

        instrument.emit(action: OAVTAction.End, trackerId: trackerId)
        event = backend.getLastEvent()!
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inPlaybackBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inPauseBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inBufferBlock) as! Bool)
        XCTAssertFalse(event.getAttribute(key: OAVTAttribute.inSeekBlock) as! Bool)
    }
    
    func testBuffers() {
        let simpleBuffer = OAVTBuffer(size: 4)

        XCTAssertTrue(simpleBuffer.put(sample: OAVTEvent(action: OAVTAction.Start)))

        Thread.sleep(forTimeInterval: 0.05)

        XCTAssertTrue(simpleBuffer.put(sample: OAVTEvent(action: OAVTAction.BufferBegin)))

        Thread.sleep(forTimeInterval: 0.05)

        XCTAssertTrue(simpleBuffer.put(sample: OAVTEvent(action: OAVTAction.BufferFinish)))

        Thread.sleep(forTimeInterval: 0.05)

        XCTAssertTrue(simpleBuffer.put(sample: OAVTEvent(action: OAVTAction.End)))

        Thread.sleep(forTimeInterval: 0.05)

        XCTAssertFalse(simpleBuffer.put(sample: OAVTEvent(action: OAVTAction.Ping)))

        Thread.sleep(forTimeInterval: 0.05)

        XCTAssertTrue(simpleBuffer.set(at: 0, sample: OAVTEvent(action: OAVTAction.Error)))

        let samples = simpleBuffer.retrieveInOrder()
        XCTAssertEqual((samples[0] as! OAVTEvent).getAction(), OAVTAction.BufferBegin)
        XCTAssertEqual((samples[1] as! OAVTEvent).getAction(), OAVTAction.BufferFinish)
        XCTAssertEqual((samples[2] as! OAVTEvent).getAction(), OAVTAction.End)
        XCTAssertEqual((samples[3] as! OAVTEvent).getAction(), OAVTAction.Error)

        //NOTE: Can't test reservoir buffer because is not predictable, due to it's random nature.
    }
    
    private func createInstrument() -> (OAVTInstrument, Int) {
        let instrument = OAVTInstrument(hub: OAVTHubCore(), backend: DummyBackend())
        let trackerId = instrument.addTracker(DummyTracker())
        instrument.ready()
        return (instrument, trackerId)
    }
}

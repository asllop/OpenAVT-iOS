//
//  OAVTHubCore.swift
//  OpenAVT-Core
//
//  Created by asllop on 27/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OAVT hub for generic content players.
open class OAVTHubCore : OAVTHubProtocol {
    private var countErrors = 0
    private var countStarts = 0
    private var accumPauseTime = 0
    private var accumSeekTime = 0
    private var accumBufferTime = 0
    private var lastBufferBeginInPauseBlock = false
    private var lastBufferBeginInSeekBlock = false
    private var streamId : String?
    private var playbackId : String?
    private var timestampOfLastEventOnPlayback : TimeInterval = 0
    private weak var instrument: OAVTInstrument?
    
    public init() {
    }
    
    deinit {
        OAVTLog.verbose("##### OAVTHubCore deinit")
    }
    
    open func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent? {
        // In case of playing again the same stream after it finished
        if tracker.getState().didFinish {
            tracker.getState().didStart = false
            tracker.getState().isPaused = false
            tracker.getState().isBuffering = false
            tracker.getState().isSeeking = false
            tracker.getState().didFinish = false
        }
        
        initPlaybackId(event: event)
        
        if tracker.getState().didStart && !tracker.getState().isPaused && !tracker.getState().isSeeking && !tracker.getState().isBuffering {
            event.setAttribute(key: OAVTAttribute.DELTA_PLAY_TIME, value: Int((NSDate().timeIntervalSince1970 - timestampOfLastEventOnPlayback)*1000))
        }
        
        if !acceptOrRejectEvent(event: event, tracker: tracker) {
            return nil
        }
        
        // Once we get here, the event has been accepted by the Hub
        
        timestampOfLastEventOnPlayback = NSDate().timeIntervalSince1970
        
        event.setAttribute(key: OAVTAttribute.COUNT_ERRORS, value: countErrors)
        event.setAttribute(key: OAVTAttribute.COUNT_STARTS, value: countStarts)
        event.setAttribute(key: OAVTAttribute.ACCUM_PAUSE_TIME, value: accumPauseTime)
        event.setAttribute(key: OAVTAttribute.ACCUM_BUFFER_TIME, value: accumBufferTime)
        event.setAttribute(key: OAVTAttribute.ACCUM_SEEK_TIME, value: accumSeekTime)
        // In case the BUFFER_BEGIN happens inside a block, we want the BUFFER_FINISH be flagged as belonging to the same block, even if it happened outside of it
        if event.getAction() == OAVTAction.BUFFER_FINISH {
            event.setAttribute(key: OAVTAttribute.IN_PAUSE_BLOCK, value: lastBufferBeginInPauseBlock)
            event.setAttribute(key: OAVTAttribute.IN_SEEK_BLOCK, value: lastBufferBeginInSeekBlock)
        }
        else {
            event.setAttribute(key: OAVTAttribute.IN_PAUSE_BLOCK, value: tracker.getState().isPaused)
            event.setAttribute(key: OAVTAttribute.IN_SEEK_BLOCK, value: tracker.getState().isSeeking)
        }
        event.setAttribute(key: OAVTAttribute.IN_BUFFER_BLOCK, value: tracker.getState().isBuffering)
        event.setAttribute(key: OAVTAttribute.IN_PLAYBACK_BLOCK, value: tracker.getState().didStart && !tracker.getState().didFinish)
        
        if let streamId = self.streamId {
            event.setAttribute(key: OAVTAttribute.STREAM_ID, value: streamId)
        }
        
        if let playbackId = self.playbackId {
            event.setAttribute(key: OAVTAttribute.PLAYBACK_ID, value: playbackId)
        }
        
        updatePlaybackId(event: event)
        
        return event
    }
    
    open func instrumentReady(instrument: OAVTInstrument) {
        self.instrument = instrument
    }
    
    open func endOfService() {
        
    }
    
    /**
     Setup ping timer.
     
     - Parameters:
        - tracker: Tracker instance.
    */
    open func startPing(tracker: OAVTTrackerProtocol) {
        self.instrument?.startPing(trackerId: tracker.trackerId!, interval: 30.0)
    }
    
    /**
     Process event, accepting or rejecting, and mutate states if necessary.
     
     - Parameters:
        - event: Event object.
        - tracker: Tracker instance.
     
     - Returns: True if accept, false if reject.
    */
    open func acceptOrRejectEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> Bool {
        
        switch event.getAction() {
        case OAVTAction.MEDIA_REQUEST:
            if !tracker.getState().didMediaRequest {
                tracker.getState().didMediaRequest = true
            }
            else {
                return false
            }
        case OAVTAction.PLAYER_SET:
            if !tracker.getState().didPlayerSet {
                tracker.getState().didPlayerSet = true
            }
            else {
                return false
            }
        case OAVTAction.STREAM_LOAD:
            if !tracker.getState().didStreamLoad {
                tracker.getState().didStreamLoad = true
                streamId = UUID().uuidString
            }
            else {
                return false
            }
        case OAVTAction.START:
            if !tracker.getState().didStart {
                startPing(tracker: tracker)
                tracker.getState().didStart = true
                countStarts = countStarts + 1
            }
            else {
                return false
            }
        case OAVTAction.PAUSE_BEGIN:
            if tracker.getState().didStart && !tracker.getState().isPaused {
                tracker.getState().isPaused = true
            }
            else {
                return false
            }
        case OAVTAction.PAUSE_FINISH:
            if tracker.getState().didStart && tracker.getState().isPaused {
                tracker.getState().isPaused = false
                let timeSincePauseBegin = event.getAttribute(key: OAVTAction.PAUSE_BEGIN.getTimeAttribute())
                accumPauseTime = accumPauseTime + (timeSincePauseBegin as! Int)
            }
            else {
                return false
            }
        case OAVTAction.BUFFER_BEGIN:
            if !tracker.getState().isBuffering {
                tracker.getState().isBuffering = true
                lastBufferBeginInPauseBlock = tracker.getState().isPaused
                lastBufferBeginInSeekBlock = tracker.getState().isSeeking
            }
            else {
                return false
            }
        case OAVTAction.BUFFER_FINISH:
            if tracker.getState().isBuffering {
                tracker.getState().isBuffering = false
                let timeSinceBufferBegin = event.getAttribute(key: OAVTAction.BUFFER_BEGIN.getTimeAttribute())
                accumBufferTime = accumBufferTime + (timeSinceBufferBegin as! Int)
            }
            else {
                return false
            }
        case OAVTAction.SEEK_BEGIN:
            if !tracker.getState().isSeeking {
                tracker.getState().isSeeking = true
            }
            else {
                return false
            }
        case OAVTAction.SEEK_FINISH:
            if tracker.getState().isSeeking {
                tracker.getState().isSeeking = false
                let timeSinceSeekBegin = event.getAttribute(key: OAVTAction.SEEK_BEGIN.getTimeAttribute())
                accumSeekTime = accumSeekTime + (timeSinceSeekBegin as! Int)
            }
            else {
                return false
            }
        case OAVTAction.END, OAVTAction.STOP, OAVTAction.NEXT:
            if tracker.getState().didStart && !tracker.getState().didFinish {
                self.instrument?.stopPing(trackerId: tracker.trackerId!)
                tracker.getState().didFinish = true
            }
            else {
                return false
            }
        case OAVTAction.ERROR:
            countErrors = countErrors + 1
        default:
            return true
        }
        
        return true
    }

    private func initPlaybackId(event: OAVTEvent) {
        if event.getAction() == OAVTAction.MEDIA_REQUEST || event.getAction() == OAVTAction.STREAM_LOAD {
            if playbackId == nil {
                playbackId = UUID().uuidString
            }
        }
    }
    
    private func updatePlaybackId(event: OAVTEvent) {
        if event.getAction() == OAVTAction.END || event.getAction() == OAVTAction.STOP || event.getAction() == OAVTAction.NEXT {
            playbackId = UUID().uuidString
        }
    }
}

//
//  OAVTHubCore.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 27/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

open class OAVTHubCore : OAVTHubProtocol {
    
    public var state = OAVTState()
    
    private var countErrors = 0
    private var countStarts = 0
    private var accumPauseTime = 0
    private var accumSeekTime = 0
    private var accumBufferTime = 0
    private var lastBufferBeginInPauseBlock = false
    private var lastBufferBeginInSeekBlock = false
    private var streamId : String?
    private var playbackId : String?
    
    public init() {
    }
    
    deinit {
        OAVTLog.verbose("##### OAVTHubCore deinit")
    }
    
    open func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent? {
        // In case of playing again the same stream after it finished
        if state.didFinish {
            state.didStart = false
            state.isPaused = false
            state.isBuffering = false
            state.isSeeking = false
            state.didFinish = false
        }
        
        initPlaybackId(event: event)
        
        if event.getAction() == OAVTAction.MEDIA_REQUEST {
            if !state.didMediaRequest {
                state.didMediaRequest = true
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.PLAYER_SET {
            if !state.didPlayerSet {
                state.didPlayerSet = true
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.STREAM_LOAD {
            if !state.didStreamLoad {
                state.didStreamLoad = true
                streamId = UUID().uuidString
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.START {
            if !state.didStart {
                state.didStart = true
                countStarts = countStarts + 1
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.PAUSE_BEGIN {
            if state.didStart && !state.isPaused {
                state.isPaused = true
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.PAUSE_FINISH {
            if state.didStart && state.isPaused {
                state.isPaused = false
                let timeSincePauseBegin = event.getAttribute(key: OAVTAction.PAUSE_BEGIN.getTimeAttribute())
                accumPauseTime = accumPauseTime + (timeSincePauseBegin as! Int)
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.BUFFER_BEGIN {
            if !state.isBuffering {
                state.isBuffering = true
                lastBufferBeginInPauseBlock = state.isPaused
                lastBufferBeginInSeekBlock = state.isSeeking
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.BUFFER_FINISH {
            if state.isBuffering {
                state.isBuffering = false
                let timeSinceBufferBegin = event.getAttribute(key: OAVTAction.BUFFER_BEGIN.getTimeAttribute())
                accumBufferTime = accumBufferTime + (timeSinceBufferBegin as! Int)
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.SEEK_BEGIN {
            if !state.isSeeking {
                state.isSeeking = true
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.SEEK_FINISH {
            if state.isSeeking {
                state.isSeeking = false
                let timeSinceSeekBegin = event.getAttribute(key: OAVTAction.SEEK_BEGIN.getTimeAttribute())
                accumSeekTime = accumSeekTime + (timeSinceSeekBegin as! Int)
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.END || event.getAction() == OAVTAction.STOP || event.getAction() == OAVTAction.NEXT {
            if state.didStart && !state.didFinish {
                state.didFinish = true
            }
            else {
                return nil
            }
        }
        else if event.getAction() == OAVTAction.ERROR {
            countErrors = countErrors + 1
        }
        
        // Once we get here, the event has been accepted by the Hub
        
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
            event.setAttribute(key: OAVTAttribute.IN_PAUSE_BLOCK, value: state.isPaused)
            event.setAttribute(key: OAVTAttribute.IN_SEEK_BLOCK, value: state.isSeeking)
        }
        event.setAttribute(key: OAVTAttribute.IN_BUFFER_BLOCK, value: state.isBuffering)
        event.setAttribute(key: OAVTAttribute.IN_PLAYBACK_BLOCK, value: state.didStart && !state.didFinish)
        
        if let streamId = self.streamId {
            event.setAttribute(key: OAVTAttribute.STREAM_ID, value: streamId)
        }
        
        if let playbackId = self.playbackId {
            event.setAttribute(key: OAVTAttribute.PLAYBACK_ID, value: playbackId)
        }
        
        updatePlaybackId(event: event)
        
        return event
    }
    
    open func getState() -> OAVTState {
        return self.state
    }
    
    open func instrumentReady(instrument: OAVTInstrument) {
        
    }
    
    open func endOfService() {
        
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

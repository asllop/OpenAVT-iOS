//
//  OAVTState.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 27/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// An OpenAVT state.
open class OAVTState {
    /// Media did request flag.
    public var didMediaRequest = false
    /// Player set flag.
    public var didPlayerSet = false
    /// Stream did load flag.
    public var didStreamLoad = false
    /// Stream did start flag.
    public var didStart = false
    /// Player in buffer state flag.
    public var isBuffering = false
    /// Player in pause state flag.
    public var isPaused = false
    /// Player in seek state flag.
    public var isSeeking = false
    /// Playback finished flag.
    public var didFinish = false
    /// Player in Ad break flag.
    public var inAdBreak = false
    /// Player playing an Ad flag.
    public var inAd = false
    
    /**
     Init a new OAVTState.
     
     - Returns: A new OAVTState instance.
    */
    public init() {}
    
    /// Reset the state.
    public func reset() {
        didMediaRequest = false
        didPlayerSet = false
        didStreamLoad = false
        didStart = false
        isBuffering = false
        isPaused = false
        isSeeking = false
        didFinish = false
        inAdBreak = false
        inAd = false
    }
}

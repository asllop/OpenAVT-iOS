//
//  OAVTState.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 27/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

open class OAVTState {
    public var didMediaRequest = false
    public var didPlayerSet = false
    public var didStreamLoad = false
    public var didStart = false
    public var isBuffering = false
    public var isPaused = false
    public var isSeeking = false
    public var didFinish = false
    public var inAdBreak = false
    public var inAd = false
    
    //TODO: flags for all possible states/events/blocks
    
    public init() {}
    
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

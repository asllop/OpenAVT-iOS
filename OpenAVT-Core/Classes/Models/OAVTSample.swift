//
//  OAVTSample.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 30/12/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// An OpenAVT Sample
open class OAVTSample {
    
    /// Timestamp of the sample
    private var timestamp : TimeInterval
    
    /**
     Init a new OAVTSample.
     
     - Returns: A new OAVTSample instance.
    */
    public init() {
        timestamp = NSDate().timeIntervalSince1970
    }

    /**
     Change timestamp.
     
     - Parameters:
        - ts: New timestamp.
    */
    public func setTimestamp(ts: TimeInterval) {
        timestamp = ts
    }
    
    /**
     Get current timestamp.
     
     - Returns: Timestamp.
    */
    public func getTimestamp() -> TimeInterval {
        return timestamp
    }
}

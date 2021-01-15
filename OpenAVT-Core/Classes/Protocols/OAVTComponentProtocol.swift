//
//  OAVTComponentProtocol.swift
//  OpenAVT-Core
//
//  Created by asllop on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT base protocol for instrument components.
public protocol OAVTComponentProtocol {
    /**
     Instrument is ready. Called when the user executes `OAVTInstrument.ready()`.
     
     - Parameters:
        - instrument: Instrument.
    */
    func instrumentReady(instrument: OAVTInstrument)
    
    /// End of service. Called when a component is removed from the instrument or when `OAVTInstrument.shutdown()` is called.
    func endOfService()
}

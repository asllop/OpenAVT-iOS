//
//  OAVTBaseProtocol.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT base protocol for instrument components.
public protocol OAVTBaseProtocol {
    /**
     Instrument is ready. Called when the user executes `OAVTInstrument.ready()`.
     
     - Parameters:
        - instrument: Instrument.
    */
    func instrumentReady(instrument: OAVTInstrument)
    /// End of service. Called when an instrument component is removed from the instrument.
    func endOfService()
}

//
//  OAVTTrackerProtocol.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

public protocol OAVTTrackerProtocol: OAVTBaseProtocol {
    func initEvent(event: OAVTEvent) -> OAVTEvent?
    var trackerId : Int? { get set }
}

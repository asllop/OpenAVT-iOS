//
//  OAVTInstrumentBridge.swift
//  ExamplePlayer-ObjC
//
//  Created by Andreu Santaren on 06/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import UIKit
import AVKit
import OpenAVT_Core
import OpenAVT_AVPlayer

@objc
public class OAVTInstrumentBridge: NSObject {
    private static var instrument : OAVTInstrument?
    private static var avpTrackerId : Int?
    
    @objc
    public static func startTracking(player: AVPlayer) {
        OAVTLog.setLogLevel(OAVTLog.LogLevel.Verbose)
        self.instrument = OAVTInstrument(hub: OAVTHubCore(), backend: DummyBackend())
        self.avpTrackerId = self.instrument?.addTracker(OAVTTrackerAVPlayer(player: player))
        self.instrument?.ready()
    }
    
    @objc
    public static func stopTracking() {
        if let tracker = self.instrument?.getTracker(self.avpTrackerId ?? 0) as? OAVTTrackerAVPlayer {
            self.instrument?.emit(action: OAVTAction.STOP, tracker: tracker)
            self.instrument?.shutdown()
        }
    }
}

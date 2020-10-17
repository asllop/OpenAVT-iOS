//
//  OAVTAttribute.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 09/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

public class OAVTAttribute : Equatable, Hashable {
    
    private let attributeName: String
    
    public init(name: String) {
        self.attributeName = name
    }
    
    public func getAttributeName() -> String {
        return self.attributeName
    }
    
    public static func == (a: OAVTAttribute, b: OAVTAttribute) -> Bool {
        return a.attributeName == b.attributeName
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(attributeName)
    }
}

public extension OAVTAttribute {
    static let TRACKER_TARGET = OAVTAttribute(name: "trackerTarget")
    static let STREAM_ID = OAVTAttribute(name: "streamId")
    static let PLAYBACK_ID = OAVTAttribute(name: "playbackId")
    static let SENDER_ID = OAVTAttribute(name: "senderId")
    static let COUNT_ERRORS = OAVTAttribute(name: "countErrors")
    static let COUNT_STARTS = OAVTAttribute(name: "countStarts")
    static let ACCUM_PAUSE_TIME = OAVTAttribute(name: "accumPauseTime")
    static let ACCUM_BUFFER_TIME = OAVTAttribute(name: "accumBufferTime")
    static let ACCUM_SEEK_TIME = OAVTAttribute(name: "accumSeekTime")
    static let IN_PAUSE_BLOCK = OAVTAttribute(name: "inPauseBlock")
    static let IN_SEEK_BLOCK = OAVTAttribute(name: "inSeekBlock")
    static let IN_BUFFER_BLOCK = OAVTAttribute(name: "inBufferBlock")
    static let IN_PLAYBACK_BLOCK = OAVTAttribute(name: "inPlaybackBlock")
    static let ERROR_DESCRIPTION = OAVTAttribute(name: "errorDescription")
    static let POSITION = OAVTAttribute(name: "position")
    static let DURATION = OAVTAttribute(name: "duration")
    static let RESOLUTION_HEIGHT = OAVTAttribute(name: "resolutionHeight")
    static let RESOLUTION_WIDTH = OAVTAttribute(name: "resolutionWidth")
    static let IS_MUTED = OAVTAttribute(name: "isMuted")
    static let VOLUME = OAVTAttribute(name: "volume")
    static let FPS = OAVTAttribute(name: "fps")
    static let SOURCE = OAVTAttribute(name: "source")
    static let BITRATE = OAVTAttribute(name: "bitrate")
    static let LANGUAGE = OAVTAttribute(name: "language")
    static let SUBTITLES = OAVTAttribute(name: "subtitles")
    static let TITLE = OAVTAttribute(name: "title")
    static let IN_AD_BREAK_BLOCK = OAVTAttribute(name: "inAdBreakBlock")
    static let IN_AD_BLOCK = OAVTAttribute(name: "inAdBlock")
    static let AD_POSITION = OAVTAttribute(name: "adPosition")
    static let AD_DURATION = OAVTAttribute(name: "adDuration")
    static let AD_BUFFERED_TIME = OAVTAttribute(name: "adBufferedTime")
    static let AD_VOLUME = OAVTAttribute(name: "adVolume")
    static let AD_ROLL = OAVTAttribute(name: "adRoll")
    static let AD_DESCRIPTION = OAVTAttribute(name: "adDescription")
    static let AD_ID = OAVTAttribute(name: "adId")
    static let AD_TITLE = OAVTAttribute(name: "adTitle")
    static let AD_ADVERTISER_NAME = OAVTAttribute(name: "adAdvertiserName")
    static let AD_CREATIVE_ID = OAVTAttribute(name: "adCreativeId")
    static let AD_BITRATE = OAVTAttribute(name: "adBitrate")
    static let AD_RESOLUTION_HEIGHT = OAVTAttribute(name: "adResolutionHeight")
    static let AD_RESOLUTION_WIDTH = OAVTAttribute(name: "adResolutionWidth")
    static let AD_SYSTEM = OAVTAttribute(name: "adSystem")
}

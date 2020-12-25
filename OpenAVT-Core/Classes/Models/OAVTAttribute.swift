//
//  OAVTAttribute.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 09/09/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// An OpenAVT Attribute 
public class OAVTAttribute : Equatable, Hashable {
    
    private let attributeName: String
    
    /**
     Init a new OAVTAttribute, providing name.
     
     - Parameters:
        - name: Attribute name.
     
     - Returns: A new OAVTAttribute instance.
    */
    public init(name: String) {
        self.attributeName = name
    }
    
    /**
     Get attribute name.
     
     - Returns: Attribute name.
    */
    public func getAttributeName() -> String {
        return self.attributeName
    }
    
    /**
     Compare two OAVTAttribute instances.
     
     - Parameters:
        - a: An OAVTAttribute instance.
        - b: An OAVTAttribute instance.
     
     - Returns: True if both instance are equal (have the same action name). False otherwise.
    */
    public static func == (a: OAVTAttribute, b: OAVTAttribute) -> Bool {
        return a.attributeName == b.attributeName
    }
    
    /**
     Calculate hash.
     
     - Parameters:
        - hasher: A Hasher.
     
     - Returns: Hash of current object.
    */
    public func hash(into hasher: inout Hasher) {
        hasher.combine(attributeName)
    }
}

public extension OAVTAttribute {
    /// Tracker Target attribute. The target of the tracker (i.e.: AVPlayer, IMA, ...).
    static let TRACKER_TARGET = OAVTAttribute(name: "trackerTarget")
    /// Stream Id attribute. Identificator of the stream being played.
    static let STREAM_ID = OAVTAttribute(name: "streamId")
    /// Playback ID attribute. Identificator of the current playback.
    static let PLAYBACK_ID = OAVTAttribute(name: "playbackId")
    /// Sender ID attribute. Identificator of the sender (the instrument-tracker).
    static let SENDER_ID = OAVTAttribute(name: "senderId")
    /// Count Errors attribute. Number of errors.
    static let COUNT_ERRORS = OAVTAttribute(name: "countErrors")
    /// Count Starts attribute. Number of starts.
    static let COUNT_STARTS = OAVTAttribute(name: "countStarts")
    /// Accumulated Pause Time attribute. Total amount of time in paused state.
    static let ACCUM_PAUSE_TIME = OAVTAttribute(name: "accumPauseTime")
    /// Accumulated Buffer Time attribute. Total amount of time buffering.
    static let ACCUM_BUFFER_TIME = OAVTAttribute(name: "accumBufferTime")
    /// Accumulated Seek Time attribute. Total amount of time seeking.
    static let ACCUM_SEEK_TIME = OAVTAttribute(name: "accumSeekTime")
    /// Accumulated Play Time attribute. Total amount of time playing.
    static let ACCUM_PLAY_TIME = OAVTAttribute(name: "accumPlayTime")
    /// Delta Play Time attribute. Time playing since last event.
    static let DELTA_PLAY_TIME = OAVTAttribute(name: "deltaPlayTime")
    /// In Pause Block attribute. Player is paused.
    static let IN_PAUSE_BLOCK = OAVTAttribute(name: "inPauseBlock")
    /// In Seek Block attribute. Player is seeking.
    static let IN_SEEK_BLOCK = OAVTAttribute(name: "inSeekBlock")
    /// In Buffer Block attribute. Player is buffering.
    static let IN_BUFFER_BLOCK = OAVTAttribute(name: "inBufferBlock")
    /// In Playback Block attribute. Player is playing.
    static let IN_PLAYBACK_BLOCK = OAVTAttribute(name: "inPlaybackBlock")
    /// Error Description attribute. Error message.
    static let ERROR_DESCRIPTION = OAVTAttribute(name: "errorDescription")
    /// Position attribute. Current stream position.
    static let POSITION = OAVTAttribute(name: "position")
    /// Duration attribute. Stream duration.
    static let DURATION = OAVTAttribute(name: "duration")
    /// Resolution Height attribute. In video streams, vertical resolution.
    static let RESOLUTION_HEIGHT = OAVTAttribute(name: "resolutionHeight")
    /// Resolution Width attribute. In video streams, horizontal resolution.
    static let RESOLUTION_WIDTH = OAVTAttribute(name: "resolutionWidth")
    /// Is Muted attribute. Playback is muted.
    static let IS_MUTED = OAVTAttribute(name: "isMuted")
    /// Volume attribute. Current volume.
    static let VOLUME = OAVTAttribute(name: "volume")
    /// FPS attribute. Frames per second.
    static let FPS = OAVTAttribute(name: "fps")
    /// Source attribute. Stream source, usually an URL.
    static let SOURCE = OAVTAttribute(name: "source")
    /// Bitrate attribute. Stream bitrate.
    static let BITRATE = OAVTAttribute(name: "bitrate")
    /// Language attribute. Stream language.
    static let LANGUAGE = OAVTAttribute(name: "language")
    /// Subtitles attribute. Subtitles language.
    static let SUBTITLES = OAVTAttribute(name: "subtitles")
    /// Title attribute. Stream title.
    static let TITLE = OAVTAttribute(name: "title")
    /// Is Ads Tracker attribute. Tracker is generating Ad events.
    static let IS_ADS_TRACKER = OAVTAttribute(name: "isAdsTracker")
    /// Count Ads attribute. Number of ads.
    static let COUNT_ADS = OAVTAttribute(name: "countAds")
    /// In Ad Break Block attribute. An Ad break has started.
    static let IN_AD_BREAK_BLOCK = OAVTAttribute(name: "inAdBreakBlock")
    /// In Ad Block attribute. Currently playing an Ad.
    static let IN_AD_BLOCK = OAVTAttribute(name: "inAdBlock")
    /// Ad Position attribute. Current Ad stream position.
    static let AD_POSITION = OAVTAttribute(name: "adPosition")
    /// Ad Duration attribute. Ad stream duration.
    static let AD_DURATION = OAVTAttribute(name: "adDuration")
    /// Ad Buffered Time attribute. Amount of Ad stream buffered.
    static let AD_BUFFERED_TIME = OAVTAttribute(name: "adBufferedTime")
    /// Ad Volume attribute. Current Ad volume.
    static let AD_VOLUME = OAVTAttribute(name: "adVolume")
    /// Ad Roll attribute. Ad position within the main stream (pre, mid, post).
    static let AD_ROLL = OAVTAttribute(name: "adRoll")
    /// Ad Description attribute. Ad description.
    static let AD_DESCRIPTION = OAVTAttribute(name: "adDescription")
    /// Ad ID attribute. Ad ID.
    static let AD_ID = OAVTAttribute(name: "adId")
    /// Ad Title attribute. Ad Title.
    static let AD_TITLE = OAVTAttribute(name: "adTitle")
    /// Ad Advertiser Name attribute. Ad advertiser name.
    static let AD_ADVERTISER_NAME = OAVTAttribute(name: "adAdvertiserName")
    /// Ad Creative ID attribute. Ad creative ID.
    static let AD_CREATIVE_ID = OAVTAttribute(name: "adCreativeId")
    /// Ad Bitrate attribute. Ad stream bitrate.
    static let AD_BITRATE = OAVTAttribute(name: "adBitrate")
    /// Ad Resolution Height attribute. Ad vertical resolution.
    static let AD_RESOLUTION_HEIGHT = OAVTAttribute(name: "adResolutionHeight")
    /// Ad Resolution Width attribute. Ad horizontal resolution.
    static let AD_RESOLUTION_WIDTH = OAVTAttribute(name: "adResolutionWidth")
    /// Ad System attribute. Ad system.
    static let AD_SYSTEM = OAVTAttribute(name: "adSystem")
}

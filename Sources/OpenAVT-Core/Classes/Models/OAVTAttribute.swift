//
//  OAVTAttribute.swift
//  OpenAVT-Core
//
//  Created by asllop on 09/09/2020.
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
    static let trackerTarget = OAVTAttribute(name: "trackerTarget")
    /// Stream Id attribute. Identificator of the stream being played.
    static let streamId = OAVTAttribute(name: "streamId")
    /// Playback ID attribute. Identificator of the current playback.
    static let playbackId = OAVTAttribute(name: "playbackId")
    /// Sender ID attribute. Identificator of the sender (the instrument-tracker).
    static let senderId = OAVTAttribute(name: "senderId")
    /// Count Errors attribute. Number of errors.
    static let countErrors = OAVTAttribute(name: "countErrors")
    /// Count Starts attribute. Number of starts.
    static let countStarts = OAVTAttribute(name: "countStarts")
    /// Accumulated Pause Time attribute. Total amount of time in paused state.
    static let accumPauseTime = OAVTAttribute(name: "accumPauseTime")
    /// Accumulated Buffer Time attribute. Total amount of time buffering.
    static let accumBufferTime = OAVTAttribute(name: "accumBufferTime")
    /// Accumulated Seek Time attribute. Total amount of time seeking.
    static let accumSeekTime = OAVTAttribute(name: "accumSeekTime")
    /// Accumulated Play Time attribute. Total amount of time playing.
    static let accumPlayTime = OAVTAttribute(name: "accumPlayTime")
    /// Delta Play Time attribute. Time playing since last event.
    static let deltaPlayTime = OAVTAttribute(name: "deltaPlayTime")
    /// In Pause Block attribute. Player is paused.
    static let inPauseBlock = OAVTAttribute(name: "inPauseBlock")
    /// In Seek Block attribute. Player is seeking.
    static let inSeekBlock = OAVTAttribute(name: "inSeekBlock")
    /// In Buffer Block attribute. Player is buffering.
    static let inBufferBlock = OAVTAttribute(name: "inBufferBlock")
    /// In Playback Block attribute. Player is playing.
    static let inPlaybackBlock = OAVTAttribute(name: "inPlaybackBlock")
    /// Error Description attribute. Error message.
    static let errorDescription = OAVTAttribute(name: "errorDescription")
    /// Position attribute. Current stream position.
    static let position = OAVTAttribute(name: "position")
    /// Duration attribute. Stream duration.
    static let duration = OAVTAttribute(name: "duration")
    /// Resolution Height attribute. In video streams, vertical resolution.
    static let resolutionHeight = OAVTAttribute(name: "resolutionHeight")
    /// Resolution Width attribute. In video streams, horizontal resolution.
    static let resolutionWidth = OAVTAttribute(name: "resolutionWidth")
    /// Is Muted attribute. Playback is muted.
    static let isMuted = OAVTAttribute(name: "isMuted")
    /// Volume attribute. Current volume.
    static let volume = OAVTAttribute(name: "volume")
    /// FPS attribute. Frames per second.
    static let fps = OAVTAttribute(name: "fps")
    /// Source attribute. Stream source, usually an URL.
    static let source = OAVTAttribute(name: "source")
    /// Bitrate attribute. Stream bitrate.
    static let bitrate = OAVTAttribute(name: "bitrate")
    /// Language attribute. Stream language.
    static let language = OAVTAttribute(name: "language")
    /// Subtitles attribute. Subtitles language.
    static let subtitles = OAVTAttribute(name: "subtitles")
    /// Title attribute. Stream title.
    static let title = OAVTAttribute(name: "title")
    /// Is Ads Tracker attribute. Tracker is generating Ad events.
    static let isAdsTracker = OAVTAttribute(name: "isAdsTracker")
    /// Count Ads attribute. Number of ads.
    static let countAds = OAVTAttribute(name: "countAds")
    /// In Ad Break Block attribute. An Ad break has started.
    static let inAdBreakBlock = OAVTAttribute(name: "inAdBreakBlock")
    /// In Ad Block attribute. Currently playing an Ad.
    static let inAdBlock = OAVTAttribute(name: "inAdBlock")
    /// Ad Position attribute. Current Ad stream position.
    static let adPosition = OAVTAttribute(name: "adPosition")
    /// Ad Duration attribute. Ad stream duration.
    static let adDuration = OAVTAttribute(name: "adDuration")
    /// Ad Buffered Time attribute. Amount of Ad stream buffered.
    static let adBufferedTime = OAVTAttribute(name: "adBufferedTime")
    /// Ad Volume attribute. Current Ad volume.
    static let adVolume = OAVTAttribute(name: "adVolume")
    /// Ad Roll attribute. Ad position within the main stream (pre, mid, post).
    static let adRoll = OAVTAttribute(name: "adRoll")
    /// Ad Description attribute. Ad description.
    static let adDescription = OAVTAttribute(name: "adDescription")
    /// Ad ID attribute. Ad ID.
    static let adId = OAVTAttribute(name: "adId")
    /// Ad Title attribute. Ad Title.
    static let adTitle = OAVTAttribute(name: "adTitle")
    /// Ad Advertiser Name attribute. Ad advertiser name.
    static let adAdvertiserName = OAVTAttribute(name: "adAdvertiserName")
    /// Ad Creative ID attribute. Ad creative ID.
    static let adCreativeId = OAVTAttribute(name: "adCreativeId")
    /// Ad Bitrate attribute. Ad stream bitrate.
    static let adBitrate = OAVTAttribute(name: "adBitrate")
    /// Ad Resolution Height attribute. Ad vertical resolution.
    static let adResolutionHeight = OAVTAttribute(name: "adResolutionHeight")
    /// Ad Resolution Width attribute. Ad horizontal resolution.
    static let adResolutionWidth = OAVTAttribute(name: "adResolutionWidth")
    /// Ad System attribute. Ad system.
    static let adSystem = OAVTAttribute(name: "adSystem")
}

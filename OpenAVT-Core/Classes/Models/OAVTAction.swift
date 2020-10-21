//
//  OAVTAction.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// An OpenAVT Action
public class OAVTAction : Equatable {

    private let actionName: String
    private let timeAttribute: OAVTAttribute
    
    /**
     Init a new OAVTAction, providing name and time attribute.
     
     All actions have a name and an associated time attribute, that is used to mark the time elapsed since the last time an event with this action was sent.
     
     - Parameters:
        - name: Action name.
        - timeAttribute: Action time attribute..
     
     - Returns: A new OAVTAction instance.
    */
    public init(name: String, timeAttribute: OAVTAttribute) {
        self.actionName = name
        self.timeAttribute = timeAttribute
    }
    
    /**
     Init a new OAVTAction, providing name.
     
     The time attribute is automatically generated using the prefix "timeSince" followed by the action name.
     
     - Parameters:
        - name: Action name.
     
     - Returns: A new OAVTAction instance.
    */
    public convenience init(name: String) {
        self.init(name: name, timeAttribute: OAVTAttribute(name: "timeSince\(name)"))
    }
    
    /**
     Get the action name of an action.
     
     - Returns: The action name.
    */
    public func getActionName() -> String {
        return self.actionName
    }
    
    /**
     Get the time attribute of an action.
     
     - Returns: The time attribute.
    */
    public func getTimeAttribute() -> OAVTAttribute {
        return self.timeAttribute
    }
    
    /**
     Compare two OAVTAction instances.
     
     - Parameters:
        - a: An OAVTAction instance.
        - b: An OAVTAction instance.
     
     - Returns: True if both instance are equal (have the same action name). False otherwise.
    */
    public static func == (a: OAVTAction, b: OAVTAction) -> Bool {
        return a.actionName == b.actionName
    }
}

// Static stuff
public extension OAVTAction {
    /// Tracker Init action. Sent when a tracker is started.
    static let TRACKER_INIT = OAVTAction(name: "TrackerInit")
    /// Media Request action. Sent when an audio/video stream is requested.
    static let MEDIA_REQUEST = OAVTAction(name: "MediaRequest")
    /// Player Set action. Sent when a player instance is sent to the tracker.
    static let PLAYER_SET = OAVTAction(name: "PlayerSet")
    /// Player Ready action. Sent when the player is ready to receive commands.
    static let PLAYER_READY = OAVTAction(name: "PlayerReady")
    /// Prepare Item action. Sent when an audio/video item is prepared.
    static let PREPARE_ITEM = OAVTAction(name: "PrepareItem")
    /// Manifest Load action. Sent when the stream manifest is loaded.
    static let MANIFEST_LOAD = OAVTAction(name: "ManifestLoad")
    /// Stream Load action. Sent when an audio/video stream is loaded.
    static let STREAM_LOAD = OAVTAction(name: "StreamLoad")
    /// Start action. Sent when an stram starts playing.
    static let START = OAVTAction(name: "Start")
    /// Buffer Begin action. Sent when the player starts buffering.
    static let BUFFER_BEGIN = OAVTAction(name: "BufferBegin")
    /// Buffer Finish action. Sent when the player ends buffering.
    static let BUFFER_FINISH = OAVTAction(name: "BufferFinish")
    /// Seek Begin action. Sent when the player starts seeking.
    static let SEEK_BEGIN = OAVTAction(name: "SeekBegin")
    /// Seek Finish action. Sent when the player ends seeking.
    static let SEEK_FINISH = OAVTAction(name: "SeekFinish")
    /// Pause Begin action. Sent when the playback is paused.
    static let PAUSE_BEGIN = OAVTAction(name: "PauseBegin")
    /// Pause Finish action. Sent when the playback is resumed.
    static let PAUSE_FINISH = OAVTAction(name: "PauseFinish")
    /// Forward Begin action. Sent when the player starts fast forward.
    static let FORWARD_BEGIN = OAVTAction(name: "ForwardBegin")
    /// Forward Finish action. Sent when the player ends fast forward.
    static let FORWARD_FINISH = OAVTAction(name: "ForwardFinish")
    /// Rewind Begin action. Sent when the player starts rewind.
    static let REWIND_BEGIN = OAVTAction(name: "RewindBegin")
    /// Rewind Finish action. Sent when the player ends rewind.
    static let REWIND_FINISH = OAVTAction(name: "RewindFinish")
    /// Quality Change Up action. Sent when the stream quality goes up.
    static let QUALITY_CHANGE_UP = OAVTAction(name: "QualityChangeUp")
    /// Quality Change Down action. Sent when the stream quality goes down.
    static let QUALITY_CHANGE_DOWN = OAVTAction(name: "QualityChangeDown")
    /// Stop action. Sent when the stream is stoped by the user.
    static let STOP = OAVTAction(name: "Stop")
    /// End action. Sent when the stream ends.
    static let END = OAVTAction(name: "End")
    /// Next action. Sent when a playlist moves to the next stream in the list.
    static let NEXT = OAVTAction(name: "Next")
    /// Error action. Sent when an error happens.
    static let ERROR = OAVTAction(name: "Error")
    /// Ping action. Sent periodically when the ping timer is enabled.
    static let PING = OAVTAction(name: "Ping")
    /// Ad Break Begin action. Sent when an ad block starts.
    static let AD_BREAK_BEGIN = OAVTAction(name: "AdBreakBegin")
    /// Ad Break Finish action. Sent when an ad block ends.
    static let AD_BREAK_FINISH = OAVTAction(name: "AdBreakFinish")
    /// Ad Begin action. Sent when an ad starts playing.
    static let AD_BEGIN = OAVTAction(name: "AdBegin")
    /// Ad Finish action. Sent when an ad ends playing.
    static let AD_FINISH = OAVTAction(name: "AdFinish")
    /// Ad Pause Begin action. Sent when the an ad is paused.
    static let AD_PAUSE_BEGIN = OAVTAction(name: "AdPauseBegin")
    /// Ad Pause Finish action. Sent when the an ad is resumed.
    static let AD_PAUSE_FINISH = OAVTAction(name: "AdPauseFinish")
    /// Ad Skip action. Sent when the an ad is skipped.
    static let AD_SKIP = OAVTAction(name: "AdSkip")
    /// Ad Click action. Sent when the an ad is clicked.
    static let AD_CLICK = OAVTAction(name: "AdClick")
    /// Ad First Quartile action. Sent when the an ad reaches the first quartiles.
    static let AD_FIRST_QUARTILE = OAVTAction(name: "AdFirstQuartile")
    /// Ad Second Quartile action. Sent when the an ad reaches the second quartiles.
    static let AD_SECOND_QUARTILE = OAVTAction(name: "AdSecondQuartile")
    /// Ad Third Quartile action. Sent when the an ad reaches the third quartiles.
    static let AD_THIRD_QUARTILE = OAVTAction(name: "AdThirdQuartile")
    /// Ad Error action. Sent when an error happens during an ad.
    static let AD_ERROR = OAVTAction(name: "AdError")
}

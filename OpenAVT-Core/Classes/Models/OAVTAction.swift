//
//  OAVTAction.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

public class OAVTAction : Equatable {

    private let actionName: String
    private let timeAttribute: OAVTAttribute
    
    public init(name: String, timeAttribute: OAVTAttribute) {
        self.actionName = name
        self.timeAttribute = timeAttribute
    }
    
    public convenience init(name: String) {
        self.init(name: name, timeAttribute: OAVTAttribute(name: "timeSince\(name)"))
    }
    
    public func getActionName() -> String {
        return self.actionName
    }
    
    public func getTimeAttribute() -> OAVTAttribute {
        return self.timeAttribute
    }
    
    public static func == (a: OAVTAction, b: OAVTAction) -> Bool {
        return a.actionName == b.actionName
    }
}

// Static stuff
public extension OAVTAction {
    static let TRACKER_INIT = OAVTAction(name: "TrackerInit")
    static let MEDIA_REQUEST = OAVTAction(name: "MediaRequest")
    static let PLAYER_SET = OAVTAction(name: "PlayerSet")
    static let PLAYER_READY = OAVTAction(name: "PlayerReady")
    static let PREPARE_ITEM = OAVTAction(name: "PrepareItem")
    static let MANIFEST_LOAD = OAVTAction(name: "ManifestLoad")
    static let STREAM_LOAD = OAVTAction(name: "StreamLoad")
    static let START = OAVTAction(name: "Start")
    static let BUFFER_BEGIN = OAVTAction(name: "BufferBegin")
    static let BUFFER_FINISH = OAVTAction(name: "BufferFinish")
    static let SEEK_BEGIN = OAVTAction(name: "SeekBegin")
    static let SEEK_FINISH = OAVTAction(name: "SeekFinish")
    static let PAUSE_BEGIN = OAVTAction(name: "PauseBegin")
    static let PAUSE_FINISH = OAVTAction(name: "PauseFinish")
    static let FORWARD_BEGIN = OAVTAction(name: "ForwardBegin")
    static let FORWARD_FINISH = OAVTAction(name: "ForwardFinish")
    static let REWIND_BEGIN = OAVTAction(name: "RewindBegin")
    static let REWIND_FINISH = OAVTAction(name: "RewindFinish")
    static let QUALITY_CHANGE_UP = OAVTAction(name: "QualityChangeUp")
    static let QUALITY_CHANGE_DOWN = OAVTAction(name: "QualityChangeDown")
    static let STOP = OAVTAction(name: "Stop")
    static let END = OAVTAction(name: "End")
    static let NEXT = OAVTAction(name: "Next")
    static let ERROR = OAVTAction(name: "Error")
    static let PING = OAVTAction(name: "Ping")
    static let AD_BREAK_BEGIN = OAVTAction(name: "AdBreakBegin")
    static let AD_BREAK_FINISH = OAVTAction(name: "AdBreakFinish")
    static let AD_BEGIN = OAVTAction(name: "AdBegin")
    static let AD_FINISH = OAVTAction(name: "AdFinish")
    static let AD_PAUSE_BEGIN = OAVTAction(name: "AdPauseBegin")
    static let AD_PAUSE_FINISH = OAVTAction(name: "AdPauseFinish")
    static let AD_SKIP = OAVTAction(name: "AdSkip")
    static let AD_CLICK = OAVTAction(name: "AdClick")
    static let AD_FIRST_QUARTILE = OAVTAction(name: "AdFirstQuartile")
    static let AD_SECOND_QUARTILE = OAVTAction(name: "AdSecondQuartile")
    static let AD_THIRD_QUARTILE = OAVTAction(name: "AdThirdQuartile")
    static let AD_ERROR = OAVTAction(name: "AdError")
}

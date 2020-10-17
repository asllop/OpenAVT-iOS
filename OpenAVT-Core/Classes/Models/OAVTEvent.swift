//
//  OAVTEvent.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

public class OAVTEvent {
    
    private var action: OAVTAction
    private var attributes: Dictionary<OAVTAttribute, Any> = [:]
    
    public init(action: OAVTAction) {
        self.action = action
    }
    
    public func getAction() -> OAVTAction {
        return self.action
    }
    
    public func setAttribute(key: OAVTAttribute, value: Any) {
        self.attributes[key] = value
    }
    
    public func getAttribute(key: OAVTAttribute) -> Any? {
        return self.attributes[key]
    }
    
    public var description : String {
        var attrString = "[ "
        for (k,v) in self.attributes {
            attrString.append("\(k.getAttributeName()) = \(v) ; ")
        }
        attrString.append(" ]")
        return "<OAVTEvent : Action = \(self.action.getActionName()) , Attributes = \(attrString)>"
    }
}

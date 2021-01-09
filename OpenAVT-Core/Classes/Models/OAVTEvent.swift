//
//  OAVTEvent.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// An OpenAVT Event.
public class OAVTEvent : OAVTSample {
    
    private var action: OAVTAction
    private var attributes: Dictionary<OAVTAttribute, Any> = [:]
    
    /**
     Init a new OAVTEvent, providing action.
     
     - Parameters:
        - action: Action for the event.
     
     - Returns: A new OAVTEvent instance.
    */
    public init(action: OAVTAction) {
        self.action = action
    }
    
    /**
     Get event action.
     
     - Returns: Action.
    */
    public func getAction() -> OAVTAction {
        return self.action
    }
    
    /**
     Set attribute for event.
     
     - Parameters:
        - key: Attribute name
        - value: Attribute value.
    */
    public func setAttribute(key: OAVTAttribute, value: Any) {
        self.attributes[key] = value
    }
    
    /**
     Get attribute from event.
     
     - Parameters:
        - key: Attribute name.
     
     - Returns: Attribute value.
    */
    public func getAttribute(key: OAVTAttribute) -> Any? {
        return self.attributes[key]
    }
    
    /**
     Remove attribute from event.
     
     - Parameters:
        - key: Attribute name.
     
     - Returns: Boolean, true if attribute removed, false otherwise.
    */
    @discardableResult
    public func removeAttribute(key: OAVTAttribute) -> Bool {
        if self.attributes[key] != nil {
            self.attributes.removeValue(forKey: key)
            return true
        }
        else {
            return false
        }
    }
    
    /// Generate a readable description.
    public var description : String {
        var attrString = "[ "
        for (k,v) in self.attributes {
            attrString.append("\(k.getAttributeName()) = \(v) ; ")
        }
        attrString.append(" ]")
        return "<OAVTEvent : Action = \(self.action.getActionName()) , Timestamp = \(getTimestamp()) , Attributes = \(attrString)>"
    }
}

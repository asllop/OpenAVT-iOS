//
//  OAVTInstrument.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

public class OAVTInstrument {
    
    private let instrumentId : String
    
    private var hub : OAVTHubProtocol?
    private var backend : OAVTBackendProtocol?
    private var trackers : Dictionary<Int, OAVTTrackerProtocol> = [:]
    private var nextTrackerId : Int = 0
    private var timeSince : Dictionary<OAVTAttribute, TimeInterval> = [:]
    private var customAttributes : Dictionary<String, Dictionary<OAVTAttribute, Any>> = [:]
    private var interceptionMethod : ((OAVTEvent, OAVTTrackerProtocol)->(OAVTEvent))?
    private var pingTrackerTimers: Dictionary<Int, Timer> = [:]
    private var trackerGetters : Dictionary<Int, Dictionary<OAVTAttribute, () -> Any?>> = [:]
    
    public init() {
        self.instrumentId = UUID().uuidString
    }
    
    public convenience init(hub: OAVTHubProtocol, backend: OAVTBackendProtocol) {
        self.init()
        setHub(hub)
        setBackend(backend)
    }
    
    deinit {
        OAVTLog.verbose("##### OAVTInstrument deinit")
    }
    
    public func setHub(_ hub: OAVTHubProtocol) {
        if let hub = self.hub {
            hub.endOfService()
        }
        self.hub = hub
    }
    
    public func setBackend(_ backend: OAVTBackendProtocol) {
        if let backend = self.backend {
            backend.endOfService()
        }
        self.backend = backend
    }
    
    @discardableResult
    public func addTracker(_ tracker: OAVTTrackerProtocol) -> Int {
        var tracker = tracker
        tracker.trackerId = self.nextTrackerId
        self.trackers[self.nextTrackerId] = tracker
        self.nextTrackerId = self.nextTrackerId + 1
        return self.nextTrackerId - 1
    }
    
    public func getTrackers() -> Dictionary<Int, OAVTTrackerProtocol> {
        return self.trackers
    }
    
    public func getTracker(_ trackerId: Int) -> OAVTTrackerProtocol? {
        if let val = self.trackers[trackerId] {
            return val
        }
        else {
            return nil
        }
    }
    
    public func getHub() -> OAVTHubProtocol? {
        return self.hub
    }
    
    public func getBackend() -> OAVTBackendProtocol? {
        return self.backend
    }
    
    @discardableResult
    public func removeTracker(_ trackerId: Int) -> Bool {
        if self.trackers[trackerId] != nil {
            if let tracker = getTracker(trackerId) {
                tracker.endOfService()
            }
            self.trackers.removeValue(forKey: trackerId)
            return true
        }
        else {
            return false
        }
    }
    
    public func ready() {
        if let backend = self.backend {
            backend.instrumentReady(instrument: self)
        }
        if let hub = self.hub {
            hub.instrumentReady(instrument: self)
        }
        for (_, tracker) in self.trackers {
            tracker.instrumentReady(instrument: self)
        }
    }
    
    public func startPing(trackerId: Int, interval: TimeInterval) {
        stopPing(trackerId: trackerId)
        pingTrackerTimers[trackerId] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(pingTimerMethod), userInfo: trackerId, repeats: true)
    }
    
    public func stopPing(trackerId: Int) {
        if let t = pingTrackerTimers[trackerId] {
            t.invalidate()
        }
    }
    
    @objc private func pingTimerMethod(timer: Timer) {
        if let trackerId: Int = timer.userInfo as? Int {
            emit(action: OAVTAction.PING, trackerId: trackerId)
        }
    }
    
    public func emit(action: OAVTAction, trackerId: Int) {
        if let tracker = self.getTracker(trackerId) {
            self.emit(action: action, tracker: tracker)
        }
    }
        
    public func emit(action: OAVTAction, tracker: OAVTTrackerProtocol) {
        // Create event
        let event = generateEvent(action: action, tracker: tracker)
        // Start event jorney
        if let trackerEvent = tracker.initEvent(event: event) {
            if let hub = self.hub {
                if let hubEvent = hub.processEvent(event: trackerEvent, tracker: tracker) {
                    if let backend = self.backend {
                        if var backendEvent = backend.receiveEvent(event: hubEvent, tracker: tracker) {
                            if let interceptionMethod = self.interceptionMethod {
                                backendEvent = interceptionMethod(backendEvent, tracker)
                            }
                            backend.sendEvent(event: backendEvent)
                            // Save action timeSince, only when the event reached the end of the instrument chain
                            self.timeSince[action.getTimeAttribute()] = Date.init().timeIntervalSince1970
                        }
                    }
                }
            }
        }
    }
    
    public func setIntercept(_ method: ((OAVTEvent, OAVTTrackerProtocol)->(OAVTEvent))?) {
        self.interceptionMethod = method
    }
    
    public func addAttribute(key: OAVTAttribute, value: Any, action: OAVTAction? = nil, trackerId: Int? = nil) {
        let k = generateCustomAttributeId(action: action, trackerId: trackerId)
        if self.customAttributes[k] == nil {
            self.customAttributes[k] = [:]
        }
        self.customAttributes[k]![key] = value
    }
    
    @discardableResult
    public func removeAttribute(key: OAVTAttribute, action: OAVTAction? = nil, trackerId: Int? = nil) -> Bool{
        let k = generateCustomAttributeId(action: action, trackerId: trackerId)
        if self.customAttributes[k] != nil {
            if self.customAttributes[k]![key] != nil {
                self.customAttributes[k]!.removeValue(forKey: key)
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    public func registerGetter(attribute: OAVTAttribute, getter: @escaping () -> Any?, tracker: OAVTTrackerProtocol) {
        if let trackerId = tracker.trackerId {
            if self.trackerGetters[trackerId] == nil {
                self.trackerGetters[trackerId] = [:]
            }
            self.trackerGetters[trackerId]![attribute] = getter
        }
    }
    
    public func callGetter(attribute: OAVTAttribute, tracker: OAVTTrackerProtocol) -> Any? {
        if let trackerId = tracker.trackerId {
            if let d = self.trackerGetters[trackerId] {
                if let f = d[attribute] {
                    return f()
                }
            }
        }
        return nil
    }
    
    public func useGetter(attribute: OAVTAttribute, event: OAVTEvent, tracker: OAVTTrackerProtocol) {
        if let val = callGetter(attribute: attribute, tracker: tracker) {
            event.setAttribute(key: attribute, value: val)
        }
    }
    
    private func generateCustomAttributeId(action: OAVTAction? = nil, trackerId: Int? = nil) -> String {
        if action == nil && trackerId == nil {
            // For all
            return "5fb1f955b45e38e31789286a1790398d"  // MD5 of string "ALL"
        }
        else if action == nil && trackerId != nil {
            // For specific tracker
            return String(trackerId!)
        }
        else if trackerId == nil && action != nil {
            // For specific action
            return action!.getActionName()
        }
        else {
            // For specific action and tracker
            return action!.getActionName() + "-" + String(trackerId!)
        }
    }
    
    private func generateEvent(action: OAVTAction, tracker: OAVTTrackerProtocol) -> OAVTEvent {
        let event = OAVTEvent(action: action)
        
        // Generate attributes
        generateSenderId(tracker: tracker, event: event)
        generateTimeSince(event: event)
        generateCustomAttributes(tracker: tracker, event: event)
        
        return event
    }
    
    private func generateSenderId(tracker: OAVTTrackerProtocol, event: OAVTEvent) {
        if let tId = tracker.trackerId {
            event.setAttribute(key: OAVTAttribute.SENDER_ID, value: "\(self.instrumentId)-\(tId)")
        }
    }
    
    private func generateTimeSince(event: OAVTEvent) {
        for (attribute, timestamp) in self.timeSince {
            let timeSince = Int(1000.0 * (Date.init().timeIntervalSince1970 - timestamp))
            event.setAttribute(key: attribute, value: timeSince)
        }
    }
    
    private func generateCustomAttributes(tracker: OAVTTrackerProtocol, event: OAVTEvent) {
        if let tId = tracker.trackerId {
            let allKey = generateCustomAttributeId()
            if let allAttrs = self.customAttributes[allKey] {
                for (k,v) in allAttrs {
                    event.setAttribute(key: k, value: v)
                }
            }
            let trackerIdKey = generateCustomAttributeId(trackerId: tId)
            if let trackerIdAttrs = self.customAttributes[trackerIdKey] {
                for (k,v) in trackerIdAttrs {
                    event.setAttribute(key: k, value: v)
                }
            }
            let actionKey = generateCustomAttributeId(action: event.getAction())
            if let actionKeyAttrs = self.customAttributes[actionKey] {
                for (k,v) in actionKeyAttrs {
                    event.setAttribute(key: k, value: v)
                }
            }
            let actionTrackerIdKey = generateCustomAttributeId(action: event.getAction(), trackerId: tId)
            if let actionTrackerIdKeyAttrs = self.customAttributes[actionTrackerIdKey] {
                for (k,v) in actionTrackerIdKeyAttrs {
                    event.setAttribute(key: k, value: v)
                }
            }
        }
    }
}

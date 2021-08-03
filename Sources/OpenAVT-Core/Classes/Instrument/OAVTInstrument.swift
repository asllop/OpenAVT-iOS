//
//  OAVTInstrument.swift
//  OpenAVT-Core
//
//  Created by asllop on 20/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// An OpenAVT Instrument.
public class OAVTInstrument {
    
    private let instrumentId : String
    
    private var hub : OAVTHubProtocol?
    private var metricalc : OAVTMetricalcProtocol?
    private var backend : OAVTBackendProtocol?
    private var trackers : Dictionary<Int, OAVTTrackerProtocol> = [:]
    private var nextTrackerId : Int = 0
    private var timeSince : Dictionary<OAVTAttribute, TimeInterval> = [:]
    private var pingTrackerTimers: Dictionary<Int, Timer> = [:]
    private var trackerGetters : Dictionary<Int, Dictionary<OAVTAttribute, (() -> Any?, (OAVTEvent, OAVTAttribute) -> Bool)>> = [:]
    
    /**
     Init a new OAVTInstrument.
     
     - Returns: An empty OAVTInstrument instance.
    */
    public init() {
        self.instrumentId = UUID().uuidString
    }

    /**
     Init a new OAVTInstrument, providing hub and backend.
     
     - Parameters:
        - hub: An object conforming to OAVTHubProtocol.
        - backend: An object conforming to OAVTBackendProtocol.
     
     - Returns: A new OAVTInstrument instance.
    */
    public convenience init(hub: OAVTHubProtocol, backend: OAVTBackendProtocol) {
        self.init()
        setHub(hub)
        setBackend(backend)
    }
    
    /**
     Init a new OAVTInstrument, providing hub, metricalc and backend.
     
     - Parameters:
        - hub: An object conforming to OAVTHubProtocol.
        - metricalc: An object conforming to OAVTMetricalcProtocol.
        - backend: An object conforming to OAVTBackendProtocol.
     
     - Returns: A new OAVTInstrument instance.
    */
    public convenience init(hub: OAVTHubProtocol, metricalc: OAVTMetricalcProtocol, backend: OAVTBackendProtocol) {
        self.init(hub: hub, backend: backend)
        setMetricalc(metricalc)
    }
    
    deinit {
        OAVTLog.verbose("##### OAVTInstrument deinit")
    }

    /**
     Set the hub instance.
     
     - Parameters:
        - hub: An object conforming to OAVTHubProtocol.
    */
    public func setHub(_ hub: OAVTHubProtocol) {
        if let hub = self.hub {
            hub.endOfService()
        }
        self.hub = hub
    }
    
    /**
     Set the metricalc instance.
     
     - Parameters:
        - metricalc: An object conforming to OAVTMetricalcProtocol.
    */
    public func setMetricalc(_ metricalc: OAVTMetricalcProtocol) {
        if let metricalc = self.metricalc {
            metricalc.endOfService()
        }
        self.metricalc = metricalc
    }
    
    /**
     Set the backend instance.
     
     - Parameters:
        - backend: An object conforming to OAVTBackendProtocol.
    */
    public func setBackend(_ backend: OAVTBackendProtocol) {
        if let backend = self.backend {
            backend.endOfService()
        }
        self.backend = backend
    }
    
    /**
     Add a tracker instance.
     
     - Parameters:
        - tracker: An object conforming to OAVTTrackerProtocol.
     
     - Returns: The Tracker ID.
    */
    @discardableResult
    public func addTracker(_ tracker: OAVTTrackerProtocol) -> Int {
        var tracker = tracker
        tracker.trackerId = self.nextTrackerId
        self.trackers[self.nextTrackerId] = tracker
        self.nextTrackerId = self.nextTrackerId + 1
        return self.nextTrackerId - 1
    }
    
    /**
     Get the list of trackers.
     
     - Returns: Dictionary of trackers, using tracker ID as a key.
    */
    public func getTrackers() -> Dictionary<Int, OAVTTrackerProtocol> {
        return self.trackers
    }
    
    /**
     Get one specific tracker.
     
     - Parameters:
        - trackerId: Tracker ID.
     
     - Returns: A tracker.
    */
    public func getTracker(_ trackerId: Int) -> OAVTTrackerProtocol? {
        return self.trackers[trackerId]
    }
    
    /**
     Get the hub.
     
     - Returns: A hub.
    */
    public func getHub() -> OAVTHubProtocol? {
        return self.hub
    }
    
    /**
     Get the metricalc.
     
     - Returns: A metricalc.
    */
    public func getMetricalc() -> OAVTMetricalcProtocol? {
        return self.metricalc
    }
    
    /**
     Get the backend.
     
     - Returns: A backend.
    */
    public func getBackend() -> OAVTBackendProtocol? {
        return self.backend
    }
    
    /**
     Remove a tracker.
     
     - Parameters:
        - trackerId: Tracker ID.
     
     - Returns: True if removed, False otherwise.
    */
    @discardableResult
    public func removeTracker(_ trackerId: Int) -> Bool {
        if self.trackers[trackerId] != nil {
            if let tracker = getTracker(trackerId) {
                tracker.endOfService()
                self.trackerGetters.removeValue(forKey: trackerId)
            }
            self.trackers.removeValue(forKey: trackerId)
            return true
        }
        else {
            return false
        }
    }
    
    /**
     Tell the instrument chain everything is ready to start.
     
     It calls the `instrumentReady` method of all chain components (trackers, hub, metricalc and backend).
    */
    public func ready() {
        if let backend = self.backend {
            backend.instrumentReady(instrument: self)
        }
        if let metricalc = self.metricalc {
            metricalc.instrumentReady(instrument: self)
        }
        if let hub = self.hub {
            hub.instrumentReady(instrument: self)
        }
        for (_, tracker) in self.trackers {
            tracker.instrumentReady(instrument: self)
        }
    }
    
    /**
     Tell the instrument chain the job is done and we are shutting down.
     
     It calls the `endOfService` method of all chain components (trackers, hub, metricalc and backend).
    */
    public func shutdown() {
        for (trackerId, tracker) in self.trackers {
            tracker.endOfService()
            self.trackerGetters.removeValue(forKey: trackerId)
        }
        if let hub = self.hub {
            hub.endOfService()
        }
        if let metricalc = self.metricalc {
            metricalc.endOfService()
        }
        if let backend = self.backend {
            backend.endOfService()
        }
    }
    
    /**
     Start PING timer.
     
     Once called it will start sending PING events every `interval` using the tracker specified in `trackerId`.
     
     - Parameters:
        - trackerId: Tracker ID.
        - interval: The timer interval of the timer.
    */
    public func startPing(trackerId: Int, interval: TimeInterval) {
        stopPing(trackerId: trackerId)
        pingTrackerTimers[trackerId] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(pingTimerMethod), userInfo: trackerId, repeats: true)
    }
    
    /**
     Stop PING timer.
     
     - Parameters:
        - trackerId: Tracker ID.
    */
    public func stopPing(trackerId: Int) {
        if let t = pingTrackerTimers[trackerId] {
            t.invalidate()
        }
    }
    
    @objc private func pingTimerMethod(timer: Timer) {
        if let trackerId: Int = timer.userInfo as? Int {
            emit(action: OAVTAction.Ping, trackerId: trackerId)
        }
    }
    
    /**
     Emit an event.
     
     It generates an `OAVTEvent` using the specified action and emits it using the specified tracker.
     
     - Parameters:
        - action: Action.
        - trackerId: Tracker ID.
    */
    public func emit(action: OAVTAction, trackerId: Int) {
        if let tracker = self.getTracker(trackerId) {
            self.emit(action: action, tracker: tracker)
        }
    }
    
    /**
     Emit an event.
     
     It generates an `OAVTEvent` using the specified action and emits it using the specified tracker.
     
     - Parameters:
        - action: Action.
        - tracker: Tracker.
    */
    public func emit(action: OAVTAction, tracker: OAVTTrackerProtocol) {
        // Create event
        let event = generateEvent(action: action, tracker: tracker)
        // Start event jorney
        if let trackerEvent = tracker.initEvent(event: event) {
            if let hub = self.hub {
                if let hubEvent = hub.processEvent(event: trackerEvent, tracker: tracker) {
                    if let backend = self.backend {
                        if let metricalc = self.metricalc {
                            for metric in metricalc.processMetric(event: hubEvent, tracker: tracker) {
                                backend.sendMetric(metric: metric)
                            }
                        }
                        backend.sendEvent(event: hubEvent)
                        
                        // Save action timeSince, only when the event reached the end of the instrument chain
                        self.timeSince[action.getTimeAttribute()] = Date.init().timeIntervalSince1970
                    }
                }
            }
        }
    }
    
    /**
     Register an attribute getter for a tracker.
     
     - Parameters:
        - attribute: An OAVTAttribute.
        - getter: Code block. It must return the attribute value.
        - tracker: Tracker.
        - filter: Code block. If it returns true the attribute will be automatically added to the event. If false, it will be ignored.
    */
    public func registerGetter(attribute: OAVTAttribute, getter: @escaping () -> Any?, tracker: OAVTTrackerProtocol, filter: @escaping (OAVTEvent, OAVTAttribute) -> Bool = { _,_ in return true }) {
        if let trackerId = tracker.trackerId {
            if self.trackerGetters[trackerId] == nil {
                self.trackerGetters[trackerId] = [:]
            }
            self.trackerGetters[trackerId]![attribute] = (getter, filter)
        }
    }
    
    /**
     Unegister an attribute getter for a tracker.
     
     - Parameters:
        - attribute: An OAVTAttribute.
        - tracker: Tracker.
    */
    public func unregisterGetter(attribute: OAVTAttribute, tracker: OAVTTrackerProtocol) {
        if let trackerId = tracker.trackerId {
            if self.trackerGetters[trackerId] != nil {
                self.trackerGetters[trackerId]!.removeValue(forKey: attribute)
            }
        }
    }
    
    /**
     Call an attribute getter.
     
     - Parameters:
        - attribute: An OAVTAttribute.
        - tracker: Tracker.
     
     - Returns: Attribute value returned by the getter code block.
    */
    public func callGetter(attribute: OAVTAttribute, tracker: OAVTTrackerProtocol) -> Any? {
        if let trackerId = tracker.trackerId {
            if let d = self.trackerGetters[trackerId] {
                if let f = d[attribute] {
                    return f.0()
                }
            }
        }
        return nil
    }
    
    /**
     Call an attribute getter and put the resulting attribute into an event, if filter returns true.
     
     - Parameters:
        - attribute: An OAVTAttribute.
        - event: An OAVTEvent.
        - tracker: Tracker.
    */
    public func useGetter(attribute: OAVTAttribute, event: OAVTEvent, tracker: OAVTTrackerProtocol) {
        if let trackerId = tracker.trackerId {
            if let d = self.trackerGetters[trackerId] {
                if let f = d[attribute] {
                    if f.1(event, attribute) {
                        if let val = f.0() {
                            event.setAttribute(key: attribute, value: val)
                        }
                    }
                }
            }
        }
    }
    
    private func generateEvent(action: OAVTAction, tracker: OAVTTrackerProtocol) -> OAVTEvent {
        let event = OAVTEvent(action: action)
        
        // Generate attributes
        generateSenderId(tracker: tracker, event: event)
        generateTimeSince(event: event)
        generateAttributesFromGetters(tracker: tracker, event: event)
        
        return event
    }
    
    private func generateSenderId(tracker: OAVTTrackerProtocol, event: OAVTEvent) {
        if let tId = tracker.trackerId {
            event.setAttribute(key: OAVTAttribute.senderId, value: "\(self.instrumentId)-\(tId)")
        }
    }
    
    private func generateTimeSince(event: OAVTEvent) {
        for (attribute, timestamp) in self.timeSince {
            let timeSince = Int(1000.0 * (Date.init().timeIntervalSince1970 - timestamp))
            event.setAttribute(key: attribute, value: timeSince)
        }
    }
    
    private func generateAttributesFromGetters(tracker: OAVTTrackerProtocol, event: OAVTEvent) {
        if let trackerId = tracker.trackerId {
            if let d = self.trackerGetters[trackerId] {
                for (attr, _) in d {
                    useGetter(attribute: attr, event: event, tracker: tracker)
                }
            }
        }
    }
}

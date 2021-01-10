//
//  OAVTBackendNewrelic.swift
//  OpenAVT-NewRelic
//
//  Created by asllop on 10/01/2021.
//  Copyright © 2021 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation
import OpenAVT_Core
import NewRelic

/// OAVT backend for NewRelic
open class OAVTBackendNewrelic : OAVTBackendProtocol {
    
    private let useEvents : Bool
    private let useMetrics : Bool
    
    /**
     Init a new OAVTBackendNewrelic.
     
     - Parameters:
        - useEvents: Send events to New Relic.
        - useMetrics: Send metrics to New Relic.
     
     - Returns: A new OAVTBackendNewrelic instance.
     */
    public init(useEvents: Bool = true, useMetrics: Bool = true) {
        self.useEvents = useEvents
        self.useMetrics = useMetrics
    }
    
    public func sendEvent(event: OAVTEvent) {
        if useEvents {
            var attr = event.getDictionary()
            attr["actionName"] = buildActionName(event: event)
            if !NewRelic.recordCustomEvent(buildEventType(event: event), attributes: attr) {
                OAVTLog.error("OAVTBackendNewrelic: Could not record custom event.")
            }
        }
    }
    
    public func sendMetric(metric: OAVTMetric) {
        if useMetrics {
            NewRelic.recordMetric(withName: buildMetricName(metric: metric), category: buildMetricCategory(metric: metric), value: metric.getNSNumberValue())
        }
    }
    
    public func instrumentReady(instrument: OAVTInstrument) {}
    
    public func endOfService() {}
    
    /**
     Build a event type.
     
     Overwrite this method in a subclass to provide a custom event type.
     
     - Parameters:
        - metric: An OAVTEvent instance.
     
     - Returns: Event type.
     */
    open func buildEventType(event: OAVTEvent) -> String {
        return "OAVT"
    }
    
    /**
     Build a event action name.
     
     Overwrite this method in a subclass to provide a custom action name.
     
     - Parameters:
        - metric: An OAVTEvent instance.
     
     - Returns: Action name.
     */
    open func buildActionName(event: OAVTEvent) -> String {
        return event.getAction().getActionName()
    }
    
    /**
     Build a metric name.
     
     Overwrite this method in a subclass to provide a custom metric name.
     
     - Parameters:
        - metric: An OAVTMetric instance.
     
     - Returns: Metric name.
     */
    open func buildMetricName(metric: OAVTMetric) -> String {
        return metric.getName()
    }
    
    /**
     Build a metric category.
     
     Overwrite this method in a subclass to provide a custom metric category.
     
     - Parameters:
        - metric: An OAVTMetric instance.
     
     - Returns: Metric category.
     */
    open func buildMetricCategory(metric: OAVTMetric) -> String {
        return "OAVT"
    }
}

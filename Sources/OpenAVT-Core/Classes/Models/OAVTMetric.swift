//
//  OAVTMetric.swift
//  OpenAVT-Core
//
//  Created by asllop on 19/12/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// An OpenAVT metric.
public class OAVTMetric : OAVTSample {
    
    /// Metric types
    public enum MetricType: Int {
        /// Type counter. Sum all the values.
        case Counter = 0
        /// Type gauge. Use the last value.
        case Gauge = 1
    }
    
    private let metricName: String
    private let metricType: MetricType
    private let metricValueD: Double?
    private let metricValueI: Int?
    
    /**
     Init a new OAVTMetric, providing name, type and value.
     
     - Parameters:
        - name: Metric name.
        - type: Metric type.
        - value: Metric value, double.
     
     - Returns: A new OAVTMetric instance.
    */
    public init(name: String, type: MetricType, value: Double) {
        self.metricName = name
        self.metricType = type
        self.metricValueD = value
        self.metricValueI = nil
    }
    
    /**
     Init a new OAVTMetric, providing name, type and value.
     
     - Parameters:
        - name: Metric name.
        - type: Metric type.
        - value: Metric value, integer.
     
     - Returns: A new OAVTMetric instance.
    */
    public init(name: String, type: MetricType, value: Int) {
        self.metricName = name
        self.metricType = type
        self.metricValueI = value
        self.metricValueD = nil
    }

    /**
     Get metric name.
     
     - Returns: Name.
    */
    public func getName() -> String {
        return self.metricName
    }
    
    /**
     Get metric value.
     
     - Returns: Value.
    */
    public func getValue() -> Any {
        if let i = self.metricValueD {
            return i
        }
        else if let i = self.metricValueI {
            return i
        }
        else {
            return Double.nan
        }
    }
    
    /**
     Get metric value as Int.
     
     - Returns: Value.
    */
    public func getIntValue() -> Int? {
        return self.metricValueI
    }
    
    /**
     Get metric value as Double.
     
     - Returns: Value.
    */
    public func getDoubleValue() -> Double? {
        return self.metricValueD
    }
    
    /**
     Get metric value as NSNumber.
     
     - Returns: value.
    */
    public func getNSNumberValue() -> NSNumber {
        if let i = self.metricValueD {
            return NSNumber(value: i)
        }
        else if let i = self.metricValueI {
            return NSNumber(value: i)
        }
        else {
            return NSNumber(value: Double.nan)
        }
    }
    
    /// Generate a readable description.
    public var description : String {
        return "<OAVTMetric : Name = \(metricName) , Timestamp = \(getTimestamp()) , Type = \(self.metricType) , Value = \(self.getValue())>"
    }
}

public extension OAVTMetric {
    /// Start time metric name (gauge).
    static func StartTime(_ value: Int) -> OAVTMetric { return OAVTMetric(name: "StartTime", type: MetricType.Gauge, value: value) }
    /// Number of streams played metric name (counter).
    static func NumPlays(_ value: Int) -> OAVTMetric { return OAVTMetric(name: "NumPlays", type: MetricType.Counter, value: value) }
    /// Rebuffer time metric name (counter).
    static func RebufferTime(_ value: Int) -> OAVTMetric { return OAVTMetric(name: "RebufferTime", type: MetricType.Gauge, value: value) }
    /// Number of rebufers metric name (counter).
    static func NumRebuffers(_ value: Int) -> OAVTMetric { return OAVTMetric(name: "NumRebuffers", type: MetricType.Counter, value: value) }
    /// Playtime since last event (counter).
    static func PlayTime(_ value: Int) -> OAVTMetric { return OAVTMetric(name: "PlayTime", type: MetricType.Gauge, value: value) }
    /// Number of streams requested metric name (counter).
    static func NumRequests(_ value: Int) -> OAVTMetric { return OAVTMetric(name: "NumRequests", type: MetricType.Counter, value: value) }
    /// Number of streams loaded metric name (counter).
    static func NumLoads(_ value: Int) -> OAVTMetric { return OAVTMetric(name: "NumLoads", type: MetricType.Counter, value: value) }
    /// Number of streams ended metric name (counter).
    static func NumEnds(_ value: Int) -> OAVTMetric { return OAVTMetric(name: "NumEnds", type: MetricType.Counter, value: value) }
}

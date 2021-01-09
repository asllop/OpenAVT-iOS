//
//  OAVTMetric.swift
//  OpenAVT-Core
//
//  Created by asllop on 19/12/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// An OpenAVT metric.
open class OAVTMetric : OAVTSample {
    
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
    
    /// Generate a readable description.
    public var description : String {
        return "<OAVTMetric : Name = \(metricName) , Timestamp = \(getTimestamp()) , Type = \(self.metricType) , Value = \(self.getValue())>"
    }
}

public extension OAVTMetric {
    /// Start time metric name
    static let START_TIME = "startTime"
    /// Number of streams played metric name
    static let NUM_PLAYS = "numPlays"
    /// Rebuffer time metric name
    static let REBUFFER_TIME = "rebufferTime"
    /// Number of rebufers metric name
    static let NUM_REBUFFERS = "numRebuffers"
    /// Playtime since last event.
    static let PLAY_TIME = "playTime"
    /// Number of streams requested metric name
    static let NUM_REQUESTS = "numRequests"
    /// Number of streams loaded metric name
    static let NUM_LOADS = "numLoads"
    /// Number of streams ended metric name
    static let NUM_ENDS = "numEnds"
}

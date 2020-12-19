//
//  OAVTMetric.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 19/12/2020.
//

import Foundation

/// An OpenAVT metric.
open class OAVTMetric {
    
    private let metricName: String
    private let metricValueD: Double?
    private let metricValueI: Int?
    
    /**
     Init a new OAVTMetric, providing name and value.
     
     - Parameters:
        - name: Metric name.
        - value: Metric value, double.
     
     - Returns: A new OAVTMetric instance.
    */
    public init(name: String, value: Double) {
        self.metricName = name
        self.metricValueD = value
        self.metricValueI = nil
    }
    
    /**
     Init a new OAVTMetric, providing name and value.
     
     - Parameters:
        - name: Metric name.
        - value: Metric value, integer.
     
     - Returns: A new OAVTMetric instance.
    */
    public init(name: String, value: Int) {
        self.metricName = name
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
        return "<OAVTMetric : Name = \(metricName) , Value = \(self.getValue())>"
    }
}

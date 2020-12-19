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
    private let metricValue: Double
    
    /**
     Init a new OAVTMetric, providing name and value.
     
     - Parameters:
        - name: Metric name.
        - value: Metric value.
     
     - Returns: A new OAVTMetric instance.
    */
    public init(name: String, value: Double) {
        self.metricName = name
        self.metricValue = value
    }
    
    /// Generate a readable description.
    public var description : String {
        return "<OAVTMetric : Name = \(metricName) , Value = \(metricValue)>"
    }
}

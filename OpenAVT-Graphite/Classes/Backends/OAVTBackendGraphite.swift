//
//  OAVTBackendGraphite.swift
//  OpenAVT-Graphite
//
//  Created by Andreu Santaren on 01/01/2021.
//

import Foundation
import Network
import OpenAVT_Core

/// OAVT backend for Graphite
open class OAVTBackendGraphite : OAVTBackendProtocol {
    
    var host : String
    var port : Int
    var buffer : OAVTBuffer
    var timer : Timer?
    
    /**
     Init a new OAVTBackendGraphite.
     
     - Parameters:
        - buffer: An OAVTBuffer instance.
        - time: time interval between harvest cycles.
        - host: Graphite server host.
        - port: Graphite server port.
     
     - Returns: A new OAVTBackendGraphite instance.
    */
    public init(buffer: OAVTBuffer = OAVTReservoirBuffer(size: 500), time: TimeInterval = 30.0, host: String, port: Int = 2003) {
        self.buffer = buffer
        self.host = host
        self.port = port
        self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(pushMetrics), userInfo: nil, repeats: true)
    }
    
    deinit {
        OAVTLog.verbose("##### OAVTBackendGraphite deinit")
    }
    
    open func sendEvent(event: OAVTEvent) {}
    
    open func sendMetric(metric: OAVTMetric) {
        if buffer.put(sample: metric) {
            OAVTLog.verbose("---> SEND METRIC = \(metric.description)")
        }
    }
    
    open func instrumentReady(instrument: OAVTInstrument) {}
    
    open func endOfService() {
        timer?.invalidate()
        timer = nil
        pushMetrics()
    }
    
    /**
     Build a list of Graphite metrics using the plaintext format.
     
     - Returns: Array of formated metrics.
    */
    open func buildPlaintextMetrics() -> [String] {
        var metrics = [String]()
        for sample in buffer.retrieveInOrder() {
            if let metric = sample as? OAVTMetric {
                metrics.append("\(buildMetricName(metric)) \(metric.getValue()) \(Int(metric.getTimestamp()))")
            }
        }
        return metrics
    }
    
    /**
     Build a metric name.
     
     Overwrite this method in a subclass to provide a custom metric path.
     
     - Parameters:
        - metric: An OAVTMetric instance.
     
     - Returns: Metric path.
    */
    open func buildMetricName(_ metric: OAVTMetric) -> String {
        return "oavt.\(metric.getName())"
    }
    
    @objc func pushMetrics() {
        //TODO: push metrics to graphite
        OAVTLog.verbose("PUSH TIMER! buffer remaining = \(buffer.remaining())")
        for m in buildPlaintextMetrics() {
            OAVTLog.verbose("Metric = \(m)")
        }
    }
}

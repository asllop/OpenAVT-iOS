//
//  OAVTBackendGraphite.swift
//  OpenAVT-Graphite
//
//  Created by Andreu Santaren on 01/01/2021.
//

import Foundation
import OpenAVT_Core
import SwiftSocket

/// OAVT backend for Graphite
open class OAVTBackendGraphite : OAVTBackendProtocol {
    
    var host : String
    var port : Int
    var buffer : OAVTBuffer
    var timeInterval: TimeInterval
    var timer : Timer?
    
    private let client : TCPClient
    private var restartTimer = true
    
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
        self.timeInterval = time
        self.client = TCPClient(address: host, port: Int32(port))
        setupTimer(time: time)
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
        restartTimer = false
        //TODO: only call if not currently running
        //pushMetrics()
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
    
    open func setupTimer(time: TimeInterval) {
        OAVTLog.verbose("Setup Timer")
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: false)
    }
    
    @objc func timerHandler() {
        OAVTLog.verbose("Timer Handler")
        pushMetrics()
    }
    
    open func pushMetrics() {
        
        OAVTLog.verbose("Push Metrics! buffer remaining = \(buffer.remaining())")
        
        DispatchQueue.global(qos: .background).async {
            switch self.client.connect(timeout: 10) {
            case .success:
                OAVTLog.verbose("Connected to Graphite")
                for m in self.buildPlaintextMetrics() {
                    switch self.client.send(string: "\(m)\n" ) {
                    case .success:
                        OAVTLog.verbose("Metric Sent")
                    case .failure(let error):
                        OAVTLog.error("Failed sending m,etric to Graphite = \(error)")
                    }
                }
            case .failure(let error):
                OAVTLog.error("Failed connecting to Graphite = \(error)")
            }
            
            self.client.close()
            
            if self.restartTimer {
                DispatchQueue.main.async {
                    self.setupTimer(time: self.timeInterval)
                }
            }
        }
    }
}

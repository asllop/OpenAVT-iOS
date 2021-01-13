//
//  OAVTBackendInfluxdb.swift
//  OpenAVT-InfluxDB
//
//  Created by asllop on 09/01/2021.
//  Copyright © 2021 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation
import OpenAVT_Core

/// OAVT backend for InfluxDB
open class OAVTBackendInfluxdb : OAVTBackendProtocol {
    
    var url : URL
    var buffer : OAVTBuffer
    var timeInterval: TimeInterval
    var timer : Timer?
    
    private var restartTimer = true
    
    /**
     Init a new OAVTBackendInfluxdb.
     
     - Parameters:
        - buffer: An OAVTBuffer instance.
        - time: time interval between harvest cycles.
        - url: InfluxDB metric write URL.
     
     - Returns: A new OAVTBackendInfluxdb instance.
     */
    public init(buffer: OAVTBuffer = OAVTReservoirBuffer(size: 500), time: TimeInterval = 30.0, url: URL) {
        self.buffer = buffer
        self.url = url
        self.timeInterval = time
        setupTimer(time: time)
    }
    
    public func sendEvent(event: OAVTEvent) {}
    
    public func sendMetric(metric: OAVTMetric) {
        if buffer.put(sample: metric) {
            OAVTLog.verbose("---> SEND METRIC = \(metric.description)")
        }
    }
    
    public func instrumentReady(instrument: OAVTInstrument) {}
    
    public func endOfService() {
        timer?.invalidate()
        timer = nil
        restartTimer = false
        
        OAVTLog.verbose("Final sync")
        
        pushMetrics()
    }
    
    func buildLineMetrics() -> String {
        var metrics = ""
        for sample in buffer.retrieveInOrder() {
            if let metric = sample as? OAVTMetric {
                metrics.append(buildMetric(metric) + "\n")
            }
        }
        return metrics
    }
    
    /**
     Build a metric.
     
     Overwrite this method in a subclass to provide a custom metric format.
     
     - Parameters:
        - metric: An OAVTMetric instance.
     
     - Returns: Metric.
     */
    open func buildMetric(_ metric: OAVTMetric) -> String {
        return "\(buildMetricName(metric)) \(metric.getName())=\(metric.getValue()) \(Int64(metric.getTimestamp() * 1000000000.0))"
    }
    
    /**
     Build a metric name.
     
     Overwrite this method in a subclass to provide a custom metric path.
     
     - Parameters:
        - metric: An OAVTMetric instance.
     
     - Returns: Metric path.
     */
    open func buildMetricName(_ metric: OAVTMetric) -> String {
        return "OAVT"
    }
    
    func setupTimer(time: TimeInterval) {
        OAVTLog.verbose("Setup Timer")
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: false)
    }
    
    @objc func timerHandler() {
        OAVTLog.verbose("Timer Handler")
        pushMetrics()
    }
    
    func pushMetrics() {
        //TODO: take back metrics to buffer if push fails
        
        // Prepare URL Request Object
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = buildLineMetrics()
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                OAVTLog.error("Error pushing metrics to InflusDB = \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                OAVTLog.verbose("Sent metric to InfluxDB, response = \(dataString)")
            }
            
            if self.restartTimer {
                DispatchQueue.main.async {
                    self.setupTimer(time: self.timeInterval)
                }
            }
        }
        task.resume()
    }
}

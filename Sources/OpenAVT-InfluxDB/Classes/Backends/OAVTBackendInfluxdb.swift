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
     
     You have to specify an InfluxDB write URL. A tipical URL for a server located in the local machine, listening on port 8086 and with a database called "test":
     
        OAVTBackendInfluxdb(url: URL(string: "http://192.168.0.100:8086/write?db=test")!)
     
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
    
    public func sendEvent(event: OAVTEvent) {
        if buffer.put(sample: event) {
            OAVTLog.verbose("---> OAVTBackendInfluxdb SEND EVENT = \(event.description)")
        }
    }
    
    public func sendMetric(metric: OAVTMetric) {
        if buffer.put(sample: metric) {
            OAVTLog.verbose("---> OAVTBackendInfluxdb SEND METRIC = \(metric.description)")
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
    
    func buildLineMetrics(samples: [OAVTSample]) -> String {
        var metrics = ""
        for sample in samples {
            if let metric = sample as? OAVTMetric {
                metrics.append(buildMetric(metric) + "\n")
            }
            else if let event = sample as? OAVTEvent {
                metrics.append(buildEventMetric(event) + "\n")
            }
        }
        return metrics
    }
    
    func putBackMetrics(samples: [OAVTSample]) {
        for sample in samples {
            buffer.put(sample: sample)
        }
    }
    
    /**
     Build a metric.
     
     Overwrite this method in a subclass to provide a custom metric format.
     
     - Parameters:
        - metric: An OAVTMetric instance.
     
     - Returns: Metric.
     */
    open func buildMetric(_ metric: OAVTMetric) -> String {
        return "\(getInfluxDBPath(metric)) \(metric.getName())=\(metric.getValue()) \(Int64(metric.getTimestamp() * 1000000000.0))"
    }
    
    /**
     Build an event metric.
     
     Overwrite this method in a subclass to provide a custom metric format.
     
     - Parameters:
        - metric: An OAVTEvent instance.
     
     - Returns: Metric.
     */
    open func buildEventMetric(_ event: OAVTEvent) -> String {
        // Header
        var line = "\(getInfluxDBPath(event)) action=\"\(event.getAction().getActionName())\","
        // Body
        for (key, val) in event.getDictionary() {
            if let _ = val as? String {
                line += "\(key)=\"\(val)\","
            }
            else {
                //TODO: check if default float representation is OK for InfluxDB
                line += "\(key)=\(val),"
            }
        }
        line = String(line.dropLast())
        // Tail
        line += " \(Int64(event.getTimestamp() * 1000000000.0))"
        return line
    }
    
    /**
     Generates the InfluxDB metric path.
     
     Overwrite this method in a subclass to provide a custom metric path.
     
     - Parameters:
        - metric: An OAVTSample instance.
     
     - Returns: Metric path.
     */
    open func getInfluxDBPath(_ sample: OAVTSample) -> String {
        if let _ = sample as? OAVTMetric {
            return "OAVT_METRICS"
        }
        else if let _ = sample as? OAVTEvent {
            return "OAVT_EVENTS"
        }
        else {
            return "OAVT"
        }
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
        OAVTLog.verbose("Push Metrics! buffer remaining = \(buffer.remaining())")
        
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        
        let samples = buffer.retrieveInOrder()
        let postString = buildLineMetrics(samples: samples)
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                OAVTLog.error("Error pushing metrics to InflusDB = \(error)")
                //Put back all samples to buffer
                self.putBackMetrics(samples: samples)
            }
            else if let data = data, let dataString = String(data: data, encoding: .utf8) {
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

//
//  OAVTBackendGraphite.swift
//  OpenAVT-Graphite
//
//  Created by Andreu Santaren on 01/01/2021.
//

import Foundation
import OpenAVT_Core

open class OAVTBackendGraphite : OAVTBackendProtocol {
    
    public var host : String
    public var port : Int
    
    var buffer : OAVTBuffer
    var timer : Timer?
    
    public init(buffer: OAVTBuffer = OAVTReservoirBuffer(size: 500), time: TimeInterval = 30.0, host: String, port: Int = 2003) {
        self.buffer = buffer
        self.host = host
        self.port = port
        self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(pushTimer), userInfo: nil, repeats: true)
    }
    
    deinit {
        OAVTLog.verbose("##### OAVTBackendGraphite deinit")
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
        pushTimer()
    }
    
    @objc func pushTimer() {
        //TODO: push metrics to graphite
        OAVTLog.verbose("PUSH TIMER! buffer remaining = \(buffer.remaining())")
    }
}

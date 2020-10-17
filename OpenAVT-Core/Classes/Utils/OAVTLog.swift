//
//  OAVTLog.swift
//  OpenAVT
//
//  Created by Andreu Santaren on 31/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

public class OAVTLog {
    private static var logLevel = LogLevel.None
    
    public enum LogLevel: Int {
        case Verbose = 0
        case Debug = 1
        case Warning = 2
        case Error = 3
        case None = 4
    }
    
    private static func log(_ msg: String, _ cutLevel: LogLevel) {
        if self.logLevel.rawValue <= cutLevel.rawValue {
            Swift.print("OAVTLog(\(Date.init().timeIntervalSince1970)): \(msg)")
        }
    }

    public static func verbose(_ msg: String) {
        self.log(msg, LogLevel.Verbose)
    }
    
    public static func debug(_ msg: String) {
        self.log("[DEBUG] \(msg)", LogLevel.Debug)
    }
    
    public static func warning(_ msg: String) {
        self.log("[WARNING] \(msg)", LogLevel.Warning)
    }
    
    public static func error(_ msg: String) {
        self.log("[ERROR] \(msg)", LogLevel.Error)
    }
    
    public static func setLogLevel(_ logLevel: LogLevel) {
        self.logLevel = logLevel
    }
}

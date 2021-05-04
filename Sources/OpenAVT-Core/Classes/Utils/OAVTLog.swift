//
//  OAVTLog.swift
//  OpenAVT-Core
//
//  Created by asllop on 31/08/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT logging.
public class OAVTLog {
    private static var logLevel = LogLevel.Warning
    
    /// Log levels.
    public enum LogLevel: Int {
        /// Log level verbose.
        case Verbose = 0
        /// Log level debug.
        case Debug = 1
        /// Log level warning.
        case Warning = 2
        /// Log level error.
        case Error = 3
        /// Log level none.
        case None = 4
    }
    
    private static func log(_ msg: String, _ cutLevel: LogLevel) {
        if self.logLevel.rawValue <= cutLevel.rawValue {
            Swift.print("\(Date.init()) OAVTLog\(msg)")
        }
    }

    /**
     Print a verbose log.
     
     - Parameters:
        - msg: Message.
    */
    public static func verbose(_ msg: String) {
        self.log("[VERBOSE] \(msg)", LogLevel.Verbose)
    }
    
    /**
     Print a debug log.
     
     - Parameters:
        - msg: Message.
    */
    public static func debug(_ msg: String) {
        self.log("[DEBUG] \(msg)", LogLevel.Debug)
    }
    
    /**
     Print a warning log.
     
     - Parameters:
        - msg: Message.
    */
    public static func warning(_ msg: String) {
        self.log("[WARNING] \(msg)", LogLevel.Warning)
    }
    
    /**
     Print an error log.
     
     - Parameters:
        - msg: Message.
    */
    public static func error(_ msg: String) {
        self.log("[ERROR] \(msg)", LogLevel.Error)
    }
    
    /**
     Set current logging level.
     
     - Parameters:
        - loglevel: Log level.
    */
    public static func setLogLevel(_ logLevel: LogLevel) {
        self.logLevel = logLevel
    }
}

//
//  OAVTBuffer.swift
//  OpenAVT-Core
//
//  Created by asllop on 30/12/2020.
//  Copyright © 2020 Open Audio-Video Telemetry. All rights reserved.
//

import Foundation

/// OpenAVT buffer. Thread safe.
open class OAVTBuffer {
    
    /// Samples buffer
    var buffer : [OAVTSample] = []
    /// Buffer size
    var size = 0
    /// Dispatch queue
    let concurrentQueue = DispatchQueue(label: "OAVTBuffer", attributes: .concurrent)
    
    /**
     Init a new OAVTBuffer, providing size.
     
     - Parameters:
        - size: Size of the buffer.
     
     - Returns: A new OAVTBuffer instance.
    */
    public init(size: Int) {
        self.size = size
    }
    
    /**
     Put sample.
     
     - Parameters:
        - sample: An OAVTSample instance.
     
     - Returns: True if added, false otherwise.
    */
    @discardableResult
    open func put(sample: OAVTSample) -> Bool {
        concurrentQueue.sync {
            if remaining() > 0 {
                buffer.append(sample)
                return true
            }
            else {
                return false
            }
        }
    }
    
    /**
     Set sample at position.
     
     - Parameters:
        - at: Position.
        - sample: An OAVTSample instance.
     
     - Returns: True if set, false otherwise.
    */
    @discardableResult
    open func set(at: Int, sample: OAVTSample) -> Bool {
        concurrentQueue.sync {
            if at < buffer.count {
                buffer[at] = sample
                return true
            }
            else {
                return false
            }
        }
    }

    /**
     Get sample.
     
     - Parameters:
        - at: Position.
     
     - Returns: An OAVTSample instance.
    */
    open func get(at: Int) -> OAVTSample? {
        concurrentQueue.sync {
            if at < buffer.count {
                return buffer[at]
            }
            else {
                return nil
            }
        }
    }
    
    /**
     Obtain remaining space in the buffer.
     
     - Returns: Remaining space.
    */
    open func remaining() -> Int {
        concurrentQueue.sync {
            return size - buffer.count
        }
    }
    
    /**
     Obtain a copy of the buffer and flush.
     
     - Returns: Buffer.
    */
    open func retrieve() -> [OAVTSample] {
        concurrentQueue.sync {
            let tmp = buffer
            buffer = []
            return tmp
        }
    }
    
    /**
     Obtain a copy of the buffer, ordered by timestamp, and flush.
     
     - Returns: Buffer.
    */
    open func retrieveInOrder() -> [OAVTSample] {
        concurrentQueue.sync {
            var tmp = retrieve()
            tmp.sort { (A, B) -> Bool in
                return A.getTimestamp() < B.getTimestamp()
            }
            return tmp
        }
    }
}

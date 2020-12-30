//
//  OAVTBuffer.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 30/12/2020.
//

import Foundation

/// OpenAVT buffer. Thread safe.
open class OAVTBuffer {
    
    /// Samples buffer
    public var buffer : [OAVTSample] = []
    /// Buffer size
    public var size = 0
    
    private let concurrentQueue = DispatchQueue(label: "OAVTBuffer", attributes: .concurrent)
    
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
     Add sample.
     
     - Parameters:
        - sample: An OAVTSample instance.
    */
    open func put(sample: OAVTSample) {
        if usage() > 0 {
            concurrentQueue.sync {
                buffer.append(sample)
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
     Obtain free space in the buffer.
     
     - Returns: Free space.
    */
    open func usage() -> Int {
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
}

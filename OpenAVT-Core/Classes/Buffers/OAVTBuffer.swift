//
//  OAVTBuffer.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 30/12/2020.
//

import Foundation

/// OpenAVT buffer. Thread safe.
open class OAVTBuffer {
    
    private var buffer : [OAVTSample] = []
    private var size = 0
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
     Set sample at position.
     
     - Parameters:
        - at: Position.
        - sample: An OAVTSample instance.
    */
    open func set(at: Int, sample: OAVTSample) {
        concurrentQueue.sync {
            if at < buffer.count {
                buffer[at] = sample
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
    
    /**
     Obtain a copy of the buffer, ordered by timestamp, and flush.
     
     - Returns: Buffer.
    */
    open func retrieveInOrder() -> [OAVTSample] {
        concurrentQueue.sync {
            var tmp = buffer
            buffer = []
            tmp.sort { (A, B) -> Bool in
                return A.getTimestamp() < B.getTimestamp()
            }
            return tmp
        }
    }
}

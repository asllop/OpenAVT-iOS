//
//  OAVTReservoirBuffer.swift
//  OpenAVT-Core
//
//  Created by Andreu Santaren on 31/12/2020.
//

import Foundation

/// OpenAVT buffer with reservoir sampling. Thread safe.
open class OAVTReservoirBuffer : OAVTBuffer {
    
    /// Sampling index
    var samplingIndex : Int64 = 0
    
    public override init(size: Int) {
        super.init(size: size)
        samplingIndex = Int64(size)
    }
    
    @discardableResult
    open override func put(sample: OAVTSample) -> Bool {
        concurrentQueue.sync {
            if remaining() > 0 {
                // Fill the buffer
                buffer.append(sample)
                return true
            }
            else {
                // Buffer is full, start random sampling
                let j = Int64.random(in: 0..<samplingIndex)
                samplingIndex = samplingIndex +  1
                if j < size {
                    buffer[Int(j)] = sample
                    return true
                }
                else {
                    return false
                }
            }
        }
    }
}

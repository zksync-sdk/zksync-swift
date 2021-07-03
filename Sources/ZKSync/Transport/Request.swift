//
//  Request.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

struct JRPCCounter {
    static var counter = UInt64(1)
    static var lockQueue = DispatchQueue(label: "counterQueue")
    static func increment() -> UInt64 {
        var nextValue: UInt64 = 0
        lockQueue.sync {
            nextValue = JRPCCounter.counter
            JRPCCounter.counter = JRPCCounter.counter + 1
        }
        
        return nextValue
    }
}

struct JRPCRequest<T: Encodable>: Encodable {
    /// The rpc id
    public let id: UInt64 = JRPCCounter.increment()
    
    /// The jsonrpc version. Typically 2.0
    public let jsonrpc: String = "2.0"
    
    /// The jsonrpc method to be called
    public let method: String
    
    /// The jsonrpc parameters
    public let params: T?
}

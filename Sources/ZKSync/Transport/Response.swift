//
//  Response.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

struct JRPCResponse<T: Decodable>: Decodable {
    /// The rpc id
    public let id: Int
    
    /// The jsonrpc version. Typically 2.0
    public let jsonrpc: String
    
    /// The result
    public let result: T?
    
    /// The error
    public let error: JRPCError?
}

//
//  Error.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

public enum ZKSyncError: Error {
    case networkNotSupported(_ info: String)
    case malformedRequest
    case malformedResponse
    case invalidStatusCode(code: Int)
    
    case rpcError(code: Int, message: String)
}

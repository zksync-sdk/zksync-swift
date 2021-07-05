//
//  Error.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

public enum ZKSyncError: LocalizedError {
    case emptyResponse
    case invalidStatusCode(code: Int)
    
    case rpcError(code: Int, message: String)
    
    public var errorDescription: String? {
        switch self {
        case .rpcError(let code, let message):
            return "\(message) (\(code))"
        case .emptyResponse:
            return "Response is empty"
        case .invalidStatusCode(let code):
            return "Invalid status code: \(code)"
        }
    }
}

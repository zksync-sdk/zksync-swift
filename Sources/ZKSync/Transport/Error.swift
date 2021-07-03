//
//  Error.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

struct JRPCError: Codable {
    public let code: Int
    public let message: String
} 

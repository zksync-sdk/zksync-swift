//
//  BigInt+Extensions.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

extension BigUInt {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        let stringValue = try container.decode(String.self)
        
        self.init(stringValue.stripHexPrefix(), radix: 16)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(String(self, radix: 16).addHexPrefix())
    }
}

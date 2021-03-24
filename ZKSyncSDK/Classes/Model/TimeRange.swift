//
//  TimeRange.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/03/2021.
//

import Foundation

public struct TimeRange: Decodable {
    public var validFrom: UInt64
    public var validUntil: UInt64
    
    public init(validFrom: UInt64, validUntil: UInt64) {
        self.validFrom = validFrom
        self.validUntil = validUntil
    }
    
    public static var max: TimeRange { TimeRange(validFrom: 0, validUntil: 4294967295) }
}

//
//  ForcedExit.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 12/01/2021.
//

import Foundation
import BigInt

public class ForcedExit: ZkSyncTransaction {
    
    override public var type: String { "ForcedExit" }
    
    let initiatorAccountId: UInt32
    let target: String
    let token: UInt16
    let fee: String
    let nonce: UInt32
    let timeRange: TimeRange

    var signature: Signature?
    
    var feeInteger: BigUInt { BigUInt(fee)! }
    
    public init(initiatorAccountId: UInt32, target: String, token: UInt16, fee: String, nonce: UInt32, timeRange: TimeRange) {
        self.initiatorAccountId = initiatorAccountId
        self.target = target
        self.token = token
        self.fee = fee
        self.nonce = nonce
        self.timeRange = timeRange
    }
    
    enum CodingKeys: String, CodingKey {
        case initiatorAccountId
        case target
        case token
        case fee
        case nonce
        case type
        case signature
        case validFrom
        case validUntil
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(initiatorAccountId, forKey: .initiatorAccountId)
        try container.encode(target, forKey: .target)
        try container.encode(token, forKey: .token)
        try container.encode(fee, forKey: .fee)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(type, forKey: .type)
        try container.encode(signature, forKey: .signature)
        try container.encode(timeRange.validFrom, forKey: .validFrom)
        try container.encode(timeRange.validUntil, forKey: .validUntil)
    }
    
}

//
//  Withdraw.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 12/01/2021.
//

import Foundation
import BigInt

public class Withdraw: ZkSyncTransaction {

    override public var type: String { "Withdraw" }

    let accountId: UInt32
    let from: String
    let to: String
    let token: UInt16
    let amount: BigUInt
    let fee: String
    let nonce: UInt32
    let timeRange: TimeRange

    var signature: Signature?

    var feeInteger: BigUInt { BigUInt(fee)! }

    public init(accountId: UInt32, from: String, to: String, token: UInt16, amount: BigUInt, fee: String, nonce: UInt32, timeRange: TimeRange) {
        self.accountId = accountId
        self.from = from
        self.to = to
        self.token = token
        self.amount = amount
        self.fee = fee
        self.nonce = nonce
        self.timeRange = timeRange
    }
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case from
        case to
        case token
        case amount
        case fee
        case nonce
        case type
        case signature
        case validFrom
        case validUntil
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(token, forKey: .token)
        try container.encode(fee, forKey: .fee)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(type, forKey: .type)
        try container.encode(signature, forKey: .signature)
        try container.encode(amount.description, forKey: .amount)
        try container.encode(timeRange.validFrom, forKey: .validFrom)
        try container.encode(timeRange.validUntil, forKey: .validUntil)
    }
}


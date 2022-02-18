//
//  Order.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 21/05/2021.
//

import Foundation
import BigInt

public struct Order: Encodable {

    let accountId: UInt32
    let recepientAddress: String
    let nonce: UInt32
    let tokenBuy: UInt32
    let tokenSell: UInt32

    let ratio: (BigUInt, BigUInt)

    let amount: BigUInt
    var signature: Signature?

    let timeRange: TimeRange

    var ethereumSignature: EthSignature?

    public init(accountId: UInt32,
                  recepientAddress: String,
                  nonce: UInt32,
                  tokenBuy: UInt32,
                  tokenSell: UInt32,
                  ratio: (BigUInt, BigUInt),
                  amount: BigUInt,
                  timeRange: TimeRange) {
        self.accountId = accountId
        self.recepientAddress = recepientAddress
        self.nonce = nonce
        self.tokenBuy = tokenBuy
        self.tokenSell = tokenSell
        self.ratio = ratio
        self.amount = amount
        self.timeRange = timeRange
    }

    enum CodingKeys: String, CodingKey {
        case accountId
        case recepientAddress = "recepient"
        case nonce
        case tokenBuy
        case tokenSell
        case ratio
        case amount
        case signature
        case validFrom
        case validUntil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(accountId, forKey: .accountId)
        try container.encode(recepientAddress, forKey: .recepientAddress)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(tokenBuy, forKey: .tokenBuy)
        try container.encode(tokenSell, forKey: .tokenSell)
        try container.encode([ratio.0, ratio.1], forKey: .ratio)
        try container.encode(amount, forKey: .amount)
        try container.encode(signature, forKey: .signature)
        try container.encode(timeRange.validFrom, forKey: .validFrom)
        try container.encode(timeRange.validUntil, forKey: .validUntil)
    }
}

//
//  Swap.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 21/05/2021.
//

import Foundation
import BigInt

public class Swap: ZkSyncTransaction {

    override public var type: String { "Swap" }
    
    let submitterId: UInt32
    let submitterAddress: String
    let nonce: UInt32
    let orders: (Order, Order)
    let amounts: (BigUInt, BigUInt)
    let fee: String
    let feeToken: UInt32

    var signature: Signature?
    var feeInteger: BigUInt { BigUInt(fee)! }
    
    internal init(submitterId: UInt32, submitterAddress: String, nonce: UInt32, orders: (Order, Order), amounts: (BigUInt, BigUInt), fee: String, feeToken: UInt32, signature: Signature? = nil) {
        self.submitterId = submitterId
        self.submitterAddress = submitterAddress
        self.nonce = nonce
        self.orders = orders
        self.amounts = amounts
        self.fee = fee
        self.feeToken = feeToken
        self.signature = signature
    }
    
    enum CodingKeys: String, CodingKey {
        case submitterId
        case submitterAddress
        case nonce
        case orders
        case amounts
        case fee
        case feeToken
        case signature
        case type
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(submitterId, forKey: .submitterId)
        try container.encode(submitterAddress, forKey: .submitterAddress)
        try container.encode(orders.0, forKey: .orders)
        try container.encode(orders.1, forKey: .orders)
        try container.encode(amounts.0, forKey: .amounts)
        try container.encode(amounts.1, forKey: .amounts)
        try container.encode(signature, forKey: .signature)
        try container.encode(fee, forKey: .fee)
        try container.encode(feeToken, forKey: .feeToken)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(type, forKey: .type)
    }
}

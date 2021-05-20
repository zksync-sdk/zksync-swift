//
//  MintNFT.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/05/2021.
//

import Foundation
import BigInt

public class MintNFT: ZkSyncTransaction {

    override public var type: String { "MintNFT" }

    let creatorId: UInt32
    let creatorAddress: String
    let contentHash: String
    let recipient: String
    let fee: String
    let feeToken: UInt16
    let nonce: UInt32
    
    var signature: Signature?

    var feeInteger: BigUInt { BigUInt(fee)! }

    public init(creatorId: UInt32, creatorAddress: String, contentHash: String, recipient: String, fee: String, feeToken: UInt16, nonce: UInt32, signature: Signature? = nil) {
        self.creatorId = creatorId
        self.creatorAddress = creatorAddress
        self.contentHash = contentHash
        self.recipient = recipient
        self.fee = fee
        self.feeToken = feeToken
        self.nonce = nonce
        self.signature = signature
    }
    
    enum CodingKeys: String, CodingKey {
        case creatorId
        case creatorAddress
        case contentHash
        case recipient
        case fee
        case feeToken
        case nonce
        case type
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(creatorId, forKey: .creatorId)
        try container.encode(creatorAddress, forKey: .creatorAddress)
        try container.encode(contentHash, forKey: .contentHash)
        try container.encode(recipient, forKey: .recipient)
        try container.encode(fee, forKey: .fee)
        try container.encode(feeToken, forKey: .feeToken)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(type, forKey: .type)
    }
}

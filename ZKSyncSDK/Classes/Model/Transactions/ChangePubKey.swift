//
//  ChangePubKey.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation
import BigInt

public class ChangePubKey: ZkSyncTransaction {
    
    override public var type: String { "ChangePubKey" }
    
    let accountId: UInt32
    let account: String
    let newPkHash: String
    let feeToken: UInt16
    let fee: String
    let nonce: UInt32
    var signature: Signature?
    var ethSignature: String?
    
    var feeInteger: BigUInt { BigUInt(fee)! }
    
    public init(accountId: UInt32, account: String, newPkHash: String, feeToken: UInt16, fee: String, nonce: UInt32) {
        self.accountId = accountId
        self.account = account
        self.newPkHash = newPkHash
        self.feeToken = feeToken
        self.fee = fee
        self.nonce = nonce
    }
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case account
        case newPkHash
        case feeToken
        case fee
        case nonce
        case type
        case signature
        case ethSignature
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(account, forKey: .account)
        try container.encode(newPkHash, forKey: .newPkHash)
        try container.encode(feeToken, forKey: .feeToken)
        try container.encode(fee, forKey: .fee)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(type, forKey: .type)
        try container.encode(signature, forKey: .signature)
        try container.encode(ethSignature, forKey: .ethSignature)
    }
}

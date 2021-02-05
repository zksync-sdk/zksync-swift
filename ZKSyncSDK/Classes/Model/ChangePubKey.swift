//
//  ChangePubKey.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation
import BigInt

public struct ChangePubKey {
    let accountId: Int32
    let account: String
    let newPkHash: String
    let feeToken: UInt16
    let fee: String
    let nonce: Int32
    var signature: Signature?
    var ethSignature: Signature?
    
    var feeInteger: BigUInt { BigUInt(fee)! }
    
    public init(accountId: Int32, account: String, newPkHash: String, feeToken: UInt16, fee: String, nonce: Int32) {
        self.accountId = accountId
        self.account = account
        self.newPkHash = newPkHash
        self.feeToken = feeToken
        self.fee = fee
        self.nonce = nonce
    }
}

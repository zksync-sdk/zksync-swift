//
//  Transfer.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 12/01/2021.
//

import Foundation
import BigInt

public struct Transfer {
    let accountId: Int32
    let from: String
    let to: String
    let token: UInt16
    let amount: BigUInt
    let fee: String
    let nonce: Int32
    
    var signature: Signature?
    
    var feeInteger: BigUInt { BigUInt(fee)! }
    
    public init(accountId: Int32, from: String, to: String, token: UInt16, amount: BigUInt, fee: String, nonce: Int32) {
        self.accountId = accountId
        self.from = from
        self.to = to
        self.token = token
        self.amount = amount
        self.fee = fee
        self.nonce = nonce
    }
}

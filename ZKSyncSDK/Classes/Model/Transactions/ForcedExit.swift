//
//  ForcedExit.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 12/01/2021.
//

import Foundation
import BigInt

public struct ForcedExit: ZkSyncTransaction {
    
    public let type = "ForcedExit"
    
    let initiatorAccountId: Int32
    let target: String
    let token: UInt16
    let fee: String
    let nonce: Int32

    var signature: Signature?
    
    var feeInteger: BigUInt { BigUInt(fee)! }
    
    public init(initiatorAccountId: Int32, target: String, token: UInt16, fee: String, nonce: Int32) {
        self.initiatorAccountId = initiatorAccountId
        self.target = target
        self.token = token
        self.fee = fee
        self.nonce = nonce
    }
}

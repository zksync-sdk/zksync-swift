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

    var signature: Signature?
    
    var feeInteger: BigUInt { BigUInt(fee)! }
    
    public init(initiatorAccountId: UInt32, target: String, token: UInt16, fee: String, nonce: UInt32) {
        self.initiatorAccountId = initiatorAccountId
        self.target = target
        self.token = token
        self.fee = fee
        self.nonce = nonce
    }
}

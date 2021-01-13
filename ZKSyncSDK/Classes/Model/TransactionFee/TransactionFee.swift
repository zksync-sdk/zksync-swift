//
//  TransactionFee.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation
import BigInt

public struct TransactionFee {
    public let feeToken: String
    public let fee: BigUInt
    
    public init(feeToken: String, fee: BigUInt) {
        self.feeToken = feeToken
        self.fee = fee
    }
}

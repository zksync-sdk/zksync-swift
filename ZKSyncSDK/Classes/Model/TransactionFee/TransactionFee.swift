//
//  TransactionFee.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation
import BigInt

public struct TransactionFee {
    let feeToken: String
    let fee: BigUInt
}

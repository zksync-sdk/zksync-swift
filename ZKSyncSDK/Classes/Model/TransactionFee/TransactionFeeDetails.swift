//
//  TransactionFeeDetails.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation
import BigInt

public struct TransactionFeeDetails: Codable {
    public var gasTxAmount: String?
    public var gasPriceWei: String?
    public var gasFee: String?
    public var zkpFee: String?
    public var totalFee: String
    
    public var totalFeeInteger: BigUInt { BigUInt(totalFee)! }
}

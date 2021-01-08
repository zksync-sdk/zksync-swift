//
//  TransactionFeeDetails.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

public struct TransactionFeeDetails: Codable {
   public var gasTxAmount: String
   public var gasPriceWei: String
   public var gasFee: String
   public var zkpFee: String
   public var totalFee: String
}

//
//  TransactionFeeRequest.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

public struct TransactionFeeRequest {
    var transactionType: TransactionType
    var address: String
    var tokenIdentifier: String
}

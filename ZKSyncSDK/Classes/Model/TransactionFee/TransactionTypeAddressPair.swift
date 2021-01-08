//
//  TransactionTypeAddressPair.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

public struct TransactionTypeAddressPair {
    let transactionType: TransactionType
    let address: String
    
    public init(transactionType: TransactionType, address: String) {
        self.transactionType = transactionType
        self.address = address
    }
}

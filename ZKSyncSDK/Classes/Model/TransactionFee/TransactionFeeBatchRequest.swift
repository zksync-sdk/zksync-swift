//
//  TransactionFeeBatchRequest.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

public struct TransactionFeeBatchRequest {
    let transactionsAndAddresses: [TransactionTypeAddressPair]
    let tokenIdentifier: String
    
    public init(transactionsAndAddresses: [TransactionTypeAddressPair],
                tokenIdentifier: String) {
        self.transactionsAndAddresses = transactionsAndAddresses
        self.tokenIdentifier = tokenIdentifier
    }
}


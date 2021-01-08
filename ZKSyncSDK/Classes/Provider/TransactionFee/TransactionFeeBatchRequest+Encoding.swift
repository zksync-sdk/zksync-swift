//
//  TransactionFeeBatchRequest+Encoding.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

extension TransactionFeeBatchRequest: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.transactionsAndAddresses.map { $0.transactionType } )
        try container.encode(self.transactionsAndAddresses.map { $0.address } )
        try container.encode(tokenIdentifier)
    }
}

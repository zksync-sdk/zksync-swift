//
//  TransactionFeeRequest+Encoding.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

extension TransactionFeeRequest: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(transactionType)
        try container.encode(address)
        try container.encode(tokenIdentifier)
    }
}

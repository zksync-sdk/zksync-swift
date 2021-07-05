//
//  TransactionBatchRequest.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

struct TransactionBatchRequest: Encodable {
    let txs: [TransactionSignaturePair]
    let ethereumSignature: EthSignature?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(txs)
        try container.encode(ethereumSignature)
    }
}

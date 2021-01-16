//
//  TransactionBatchRequest.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

struct TransactionBatchRequest<TX: ZkSyncTransaction>: Encodable {
    let txs: [TransactionSignaturePair<TX>]
    let ethereumSignature: EthSignature?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(txs.map { $0.transaction })
        try container.encode(txs.map { $0.signature })
        try container.encode(ethereumSignature)
    }
}

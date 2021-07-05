//
//  TransactionRequest.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

struct TransactionRequest<Transaction: Encodable>: Encodable {
    let tx: Transaction
    let ethereumSignature: EthSignature?
    let fastProcessing: Bool
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(tx)
        if let signature = ethereumSignature{
            try container.encode(signature)
        } else {
            try container.encodeNil()
        }
        try container.encode(fastProcessing)
    }
}

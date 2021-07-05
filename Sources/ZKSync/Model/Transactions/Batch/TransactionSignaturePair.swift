//
//  TransactionSignaturePair.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

public struct TransactionSignaturePair: Encodable {
    let tx: ZkSyncTransaction
    let signature: EthSignature?
    
    public init(tx: ZkSyncTransaction, signature: EthSignature?) {
        self.tx = tx
        self.signature = signature
    }
}

//
//  DefaultProvider+Transactions.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation



extension DefaultProvider {
    public func submitTx(_ tx: ZkSyncTransaction,
                         ethereumSignature: EthSignature?,
                         fastProcessing: Bool,
                         completion: @escaping (ZKSyncResult<String>) -> Void) {
        let request = TransactionRequest(tx: tx,
                                         ethereumSignature: ethereumSignature,
                                         fastProcessing: fastProcessing)
        self.transport.send(method: "tx_submit", params: request, completion: completion)
    }
    
    public func submitTx(_ tx: ZkSyncTransaction,
                         fastProcessing: Bool,
                         completion: @escaping (ZKSyncResult<String>) -> Void) {
        self.submitTx(tx,
                      ethereumSignature: nil,
                      fastProcessing: fastProcessing,
                      completion: completion)
    }
    
    public func submitTxBatch(txs: [TransactionSignaturePair],
                              ethereumSignature: EthSignature?,
                              completion: @escaping (ZKSyncResult<[String]>) -> Void) {
        let request = TransactionBatchRequest(txs: txs,
                                              ethereumSignature: ethereumSignature)
        self.transport.send(method: "submit_txs_batch", params: request, completion: completion)
    }
    
    public func submitTxBatch(txs: [TransactionSignaturePair],
                              completion: @escaping (ZKSyncResult<[String]>) -> Void) {
        self.submitTxBatch(txs: txs, ethereumSignature: nil, completion: completion)
    }
}


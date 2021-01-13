//
//  DefaultProvider+Transactions.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

extension DefaultProvider {
    public func submitTx<TX: ZkSyncTransaction>(_ tx: TX,
                                                ethereumSignature: EthSignature?,
                                                fastProcessing: Bool,
                                                completion: @escaping (ZKSyncResult<String>) -> Void) {
        let request = TransactionRequest(tx: tx,
                                         ethereumSignature: ethereumSignature,
                                         fastProcessing: fastProcessing)
        self.transport.send(method: "tx_submit", params: request, completion: completion)
    }
    
    public func submitTx<TX: ZkSyncTransaction>(_ tx: TX,
                                         fastProcessing: Bool,
                                         completion: @escaping (ZKSyncResult<String>) -> Void) {
        self.submitTx(tx,
                      ethereumSignature: nil,
                      fastProcessing: fastProcessing,
                      completion: completion)
    }

}

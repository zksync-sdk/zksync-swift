//
//  Provider+TransactionFee.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

extension DefaultProvider {
    public func transactionFee(request: TransactionFeeRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void) {
        self.transport.send(method: "get_tx_fee", params: request, completion: completion)
    }
    
    public func transactionFee(request: TransactionFeeBatchRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void) {
        self.transport.send(method: "get_txs_batch_fee_in_wei", params: request, completion: completion)
    }
}

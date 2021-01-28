//
//  DefaultProvider+TransactionDetails.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

extension DefaultProvider {
    public func transactionDetails(txHash: String,
                                   completion: @escaping (ZKSyncResult<TransactionDetails>) -> Void) {
        transport.send(method: "tx_info", params: [txHash], completion: completion)
    }
}


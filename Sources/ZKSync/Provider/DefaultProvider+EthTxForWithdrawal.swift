//
//  DefaultProvider+EthTxForWithdrawal.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 22/01/2021.
//

import Foundation

extension DefaultProvider {
    public func ethTxForWithdrawal(withdrawalHash: String, completion: @escaping (ZKSyncResult<String>) -> Void) {
        return transport.send(method: "get_eth_tx_for_withdrawal", params: [withdrawalHash], completion: completion)
    }
}

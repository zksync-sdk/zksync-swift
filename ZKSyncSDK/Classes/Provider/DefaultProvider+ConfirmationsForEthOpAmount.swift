//
//  DefaultProvider+ConfirmationsForEthOpAmount.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation
import BigInt

extension DefaultProvider {
    public func confirmationsForEthOpAmount(completion: @escaping (ZKSyncResult<UInt64>) -> Void) {
        transport.send(method: "get_confirmations_for_eth_op_amount", params: [String](), completion: completion)
    }
}

//
//  DefaultProvider+EthOpInfo.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

extension DefaultProvider {
    public func ethOpInfo(priority: Int,
                   completion: @escaping (ZKSyncResult<EthOpInfo>) -> Void) {
        self.transport.send(method: "ethop_info", params: [priority], completion: completion)
    }
}


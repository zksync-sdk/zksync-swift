//
//  Provider+ContractAddress.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

extension DefaultProvider {
    public func contractAddress(queue: DispatchQueue, completion: @escaping (ZKSyncResult<ContractAddress>) -> Void) {
        transport.send(method: "contract_address", params: [String](), queue: queue, completion: completion)
    }
}

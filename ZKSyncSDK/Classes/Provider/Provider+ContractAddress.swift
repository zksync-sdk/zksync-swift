//
//  Provider+ContractAddress.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

extension Provider {
    public func contractAddress(completion: @escaping (ZKSyncResult<ContractAddress>) -> Void) {
        transport.send(method: "contract_address", params: [String](), completion: completion)
    }
}

//
//  Provider+ContractAddress.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

public struct ContractAddress: Codable {
    var mainContract: String
    var govContract: String
}

extension Provider {
    public func contractAddress(completion: @escaping (ZKSyncResult<ContractAddress>) -> Void) {
        transport.request(method: "contract_address", params: [String](), completion: completion)
    }
}

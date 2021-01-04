//
//  Provider+Accounts.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

public struct AccountState: Codable {
    public struct Balance: Codable {
        var amount: String
        var expectedBlockNumber: BigUInt
    }
    
    public struct Depositing: Codable {
        var balances: [String: Balance]
    }
    
    public struct State: Codable {
        var nonce: Int
        var pubKeyHash: String
        var balances: [String: String]
    }
    
    var address: String
    var id: Int
    
    var depositing: Depositing
    var committed: State
    var verified: State
}

extension Provider {
    public func accountInfo(address: String, completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        self.transport.request(method: "account_info", params: [address], completion: completion)
    }
}

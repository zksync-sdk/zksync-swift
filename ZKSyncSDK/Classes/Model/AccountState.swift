//
//  AccountState.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
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
    var id: Int?
    
    var depositing: Depositing
    var committed: State
    var verified: State
}

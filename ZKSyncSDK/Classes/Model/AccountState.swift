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
        public var nonce: Int
        public var pubKeyHash: String
        public var balances: [String: String]
    }
    
    public var address: String
    public var id: Int?
    
    public var depositing: Depositing
    public var committed: State
    public var verified: State
}

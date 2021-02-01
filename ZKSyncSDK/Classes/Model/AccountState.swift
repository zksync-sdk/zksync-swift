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
        public var amount: String
        public var expectedAcceptBlock: UInt64
    }
    
    public struct Depositing: Codable {
        public var balances: [String: Balance]
    }
    
    public struct State: Codable {
        public var nonce: UInt32
        public var pubKeyHash: String
        public var balances: [String: String]
    }
    
    public var address: String
    public var id: UInt32?
    
    public var depositing: Depositing
    public var committed: State
    public var verified: State
}

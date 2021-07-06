//
//  AccountState.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt

public struct AccountState: Decodable {
    public struct Balance: Decodable {
        public var amount: String
        public var expectedAcceptBlock: UInt64
    }
    
    public struct Depositing: Decodable {
        public var balances: [String: Balance]
    }
    
    public struct State: Decodable {
        public var nonce: UInt32
        public var pubKeyHash: String
        public var balances: [String: String]
        public var nfts: [String: NFT]?
        public var mintedNfts: [String: NFT]?
    }
    
    public var address: String
    public var id: UInt32?
    
    public var depositing: Depositing
    public var committed: State
    public var verified: State
}

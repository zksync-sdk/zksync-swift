//
//  Token.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt
import web3swift

public struct Token {
    
    let id: Int
    let address: String
    let symbol: String
    let decimals: Int
    
    static var ETH: Token {
        return Token(id: 0,
                     address: "0x0000000000000000000000000000000000000000",
                     symbol: "ETH",
                     decimals: 0)
    }
}

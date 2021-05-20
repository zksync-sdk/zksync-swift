//
//  Token.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt
import web3swift

public struct Token: TokenId, Decodable {
    
    private static let DefaultAddress = "0x0000000000000000000000000000000000000000"
    
    public let id: UInt32
    public let address: String
    public let symbol: String
    let decimals: Int
    
    public static var ETH: Token {
        return Token(id: 0,
                     address: Token.DefaultAddress,
                     symbol: "ETH",
                     decimals: 18)
    }
    
    public func intoDecimal(_ amount: BigUInt) -> Decimal {
        let sourceDecimal = Decimal(string: "\(amount)")!
        return  sourceDecimal / pow(Decimal(10), decimals)
    }

    var isETH: Bool {
        return (address == Token.DefaultAddress && symbol == "ETH")
    }
}

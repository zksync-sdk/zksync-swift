//
//  NFT.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/05/2021.
//

import Foundation
import BigInt

public struct NFT: TokenId, Decodable {
    public let id: UInt32
    public let symbol: String
    let creatorId: UInt32
    let contentHash: String

    let creatorAddress: String

    let serialId: UInt32

    let address: String
    
    public func intoDecimal(_ amount: BigUInt) -> Decimal {
        let sourceDecimal = Decimal(string: "\(amount)")!
        return  sourceDecimal / pow(Decimal(1), 1)
    }
}

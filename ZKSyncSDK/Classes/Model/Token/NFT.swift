//
//  NFT.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/05/2021.
//

import Foundation
import BigInt

public struct NFT: TokenId, Decodable {
    let id: UInt16
    let symbol: String
    let creatorId: String
    let contentHash: String

    func intoDecimal(_ amount: BigUInt) -> Decimal {
        let sourceDecimal = Decimal(string: "\(amount)")!
        return  sourceDecimal / pow(Decimal(10), 1)
    }
}

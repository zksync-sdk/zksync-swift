//
//  TokenId.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/05/2021.
//

import Foundation
import BigInt

protocol TokenId {
    var id: UInt16 { get }
    var symbol: String { get }
    
    func intoDecimal(_ amount: BigUInt) -> Decimal
}

//
//  ChainId.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation

public enum ChainId: Int {
    case mainnet = 1
    case rinkeby = 4
    case ropsten = 3
    case goerli = 420
    case sepolia = 11155111
    case localhost = 9

    public var id: Int { rawValue }
}

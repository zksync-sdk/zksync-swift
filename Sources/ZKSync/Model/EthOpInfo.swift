//
//  EthOpInfo.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

public struct EthOpInfo: Decodable {
    let executed: Bool
    let block: BlockInfo
}

//
//  BlockInfo.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

public struct BlockInfo: Decodable {
    let blockNumber: Int
    let committed: Bool
    let verified: Bool
}

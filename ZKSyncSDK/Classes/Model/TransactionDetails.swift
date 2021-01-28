//
//  TransactionDetails.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

public struct TransactionDetails: Decodable {
    let executed: Bool
    let success: Bool
    let failReason: String?
    let block: BlockInfo
}

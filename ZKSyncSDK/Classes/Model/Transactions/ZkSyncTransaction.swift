//
//  ZkSyncTransaction.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

public protocol ZkSyncTransaction: Encodable {
    var type: String { get }
}

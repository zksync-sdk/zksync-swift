//
//  ZkSyncTransaction.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

protocol ZkSyncTransaction: Encodable {
    var type: String { get }
}

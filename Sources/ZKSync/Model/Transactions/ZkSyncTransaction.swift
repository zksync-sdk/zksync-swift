//
//  ZkSyncTransaction.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

public class ZkSyncTransaction: Encodable {
    public var type: String { fatalError("Subclasses mst override 'type' property") }
}

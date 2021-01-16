//
//  TransactionSignaturePair.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation

public struct TransactionSignaturePair<TX: ZkSyncTransaction> {
    let transaction: TX
    let signature: EthSignature
}

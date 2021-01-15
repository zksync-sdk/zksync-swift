//
//  SignedTransaction.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

struct SignedTransaction<T: ZkSyncTransaction> {
    let transaction: T
    let ethereumSignature: EthSignature?
}

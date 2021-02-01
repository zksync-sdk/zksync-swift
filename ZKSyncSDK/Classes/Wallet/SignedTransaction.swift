//
//  SignedTransaction.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

public struct SignedTransaction<T> where T: ZkSyncTransaction {
    public let transaction: T
    public let ethereumSignature: EthSignature?
}

extension SignedTransaction: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case transaction = "tx"
        case ethereumSignature = "signature"
    }
}

//
//  EthSignerError.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation

public enum EthSignerError: Error {
    case invalidKey
    case invalidMessage
    case invalidMnemonic
    case signingFailed
    case invalidTransactionType(String)
    case unsupportedOperation
}

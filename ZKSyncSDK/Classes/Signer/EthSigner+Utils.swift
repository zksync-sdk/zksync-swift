//
//  EthSigner+Utils.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation

extension EthSigner {
    
    private static let MaxNumberOfAccounts: Int = 1 << 24
    private static var Formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 18
        return formatter
    }()
    
    
    func nonceToBytes(_ nonce: Int32) throws -> Data {
        if nonce < 0 {
            throw EthSignerError.negativeNonce
        }
        return nonce.bytesBE()
    }
    
    func accountIdToBytes(_ accountId: Int32) throws -> Data {
        if accountId > EthSigner.MaxNumberOfAccounts {
            throw EthSignerError.accountNumberTooLarge
        }
        return accountId.bytesBE()
    }

    func format(_ value: Decimal) -> String {
        return EthSigner.Formatter.string(from: value as NSDecimalNumber)!
    }
}

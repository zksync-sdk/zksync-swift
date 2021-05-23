//
//  DefaultWallet+Swap.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 23/05/2021.
//

import Foundation
import BigInt
import PromiseKit

extension DefaultWallet {
    public func swap(fee: TransactionFee, nonce: UInt32?, completion: @escaping (Swift.Result<[String], Error>) -> Void) {
        completion(.failure(DefaultWalletError.unsupportedOperation))
    }
}

//
//  Wallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt

public protocol Wallet {
    func getContractAddress(completion: @escaping (Result<ContractAddress, Error>) -> Void)
    func getAccountInfo(completion: @escaping (Result<AccountState, Error>) -> Void)
    func getTokenPrice(completion: @escaping (Result<Decimal, Error>) -> Void)
}


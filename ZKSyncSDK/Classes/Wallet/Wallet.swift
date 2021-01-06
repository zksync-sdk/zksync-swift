//
//  Wallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation

public protocol Wallet {
    func getContractAddress(completion: @escaping (Result<ContractAddress, Error>) -> Void)
    func getAccountInfo(completion: @escaping (Result<AccountState, Error>) -> Void)
}


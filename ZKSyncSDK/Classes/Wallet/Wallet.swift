//
//  Wallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt

public typealias ZKSyncCompletion<T> = (ZKSyncResult<T>) -> Void

public protocol Wallet {
    
    var provider: Provider { get }
    
    func getContractAddress(completion: @escaping (Result<ContractAddress, Error>) -> Void)
    func getAccountState(completion: @escaping (Result<AccountState, Error>) -> Void)
    func getTokenPrice(completion: @escaping (Result<Decimal, Error>) -> Void)

    func getTransactionFee(for transactionType:TransactionType,
                           tokenIdentifier: String,
                           completion: @escaping ZKSyncCompletion<TransactionFeeDetails>)

    func getTransactionFee(for transactionType:TransactionType,
                           address: String,
                           tokenIdentifier: String,
                           completion: @escaping ZKSyncCompletion<TransactionFeeDetails>)
 
    func getTransactionFee(for batchRequest: TransactionFeeBatchRequest,
                           completion: @escaping ZKSyncCompletion<TransactionFeeDetails>)

    func transfer(to: String, amount: BigUInt, fee: TransactionFee, nonce: Int32?, completion: @escaping (Result<String, Error>) -> Void)
}


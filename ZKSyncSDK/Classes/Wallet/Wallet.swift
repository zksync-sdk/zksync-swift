//
//  Wallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt
import web3swift

public typealias ZKSyncCompletion<T> = (ZKSyncResult<T>) -> Void

public enum WalletError: Error {
    case signingKeyAlreadySet
}

public protocol Wallet {
    
    var provider: Provider { get }
    
    func getAccountState(completion: @escaping (Result<AccountState, Error>) -> Void)
    
    func getTransactionFee(for transactionType:TransactionType,
                           tokenIdentifier: String,
                           completion: @escaping ZKSyncCompletion<TransactionFeeDetails>)

    func getTransactionFee(for transactionType:TransactionType,
                           address: String,
                           tokenIdentifier: String,
                           completion: @escaping ZKSyncCompletion<TransactionFeeDetails>)
 
    func getTransactionFee(for batchRequest: TransactionFeeBatchRequest,
                           completion: @escaping ZKSyncCompletion<TransactionFeeDetails>)

    func setSigningKey(fee: TransactionFee, nonce: Int32?, oncahinAuth: Bool, completion: @escaping (Swift.Result<String, Error>) -> Void)

    func transfer(to: String, amount: BigUInt, fee: TransactionFee, nonce: Int32?, completion: @escaping (Result<String, Error>) -> Void)
    
    func withdraw(ethAddress: String, amount: BigUInt, fee: TransactionFee, nonce: Int32?, fastProcessing: Bool, completion: @escaping (Result<String, Error>) -> Void)
    
    func forcedExit(target: String, fee: TransactionFee, nonce: Int32?, completion: @escaping (Result<String, Error>) -> Void)
    
    var isSigningKeySet: Bool { get }
    
    func createEthereumProvider(web3: web3) throws -> EthereumProvider
}


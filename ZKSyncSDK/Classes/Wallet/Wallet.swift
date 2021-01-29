//
//  Wallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt
import web3swift
import PromiseKit

public typealias ZKSyncCompletion<T> = (ZKSyncResult<T>) -> Void

public enum WalletError: Error {
    case signingKeyAlreadySet
}

public protocol Wallet {
    
    var provider: Provider { get }
    
    var address: String { get }
    
    func getAccountState(completion: @escaping (Swift.Result<AccountState, Error>) -> Void)
    
    func setSigningKey(fee: TransactionFee, nonce: UInt32?, oncahinAuth: Bool, completion: @escaping (Swift.Result<String, Error>) -> Void)

    func transfer(to: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    func withdraw(ethAddress: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, fastProcessing: Bool, completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    func forcedExit(target: String, fee: TransactionFee, nonce: UInt32?, completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    var isSigningKeySet: Bool { get }
    
    func createEthereumProvider(web3: web3) throws -> EthereumProvider
    
    func buildSignedChangePubKeyTx(fee: TransactionFee,
                                   nonce: UInt32,
                                   onchainAuth: Bool) -> Promise<SignedTransaction<ChangePubKey>>
    
    func buildSignedForcedExitTx(target: String,
                                 tokenIdentifier: String,
                                 fee: BigUInt,
                                 nonce: UInt32) -> Promise<SignedTransaction<ForcedExit>>
    
    func buildSignedTransferTx(to: String,
                               tokenIdentifier: String,
                               amount: BigUInt,
                               fee: BigUInt,
                               nonce: UInt32) -> Promise<SignedTransaction<Transfer>>
    
    func buildSignedWithdrawTx(to: String,
                                tokenIdentifier: String,
                                amount: BigUInt,
                                fee: BigUInt,
                                nonce: UInt32) -> Promise<SignedTransaction<Withdraw>>
}


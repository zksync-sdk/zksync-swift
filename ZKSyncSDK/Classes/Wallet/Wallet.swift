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
    case accountIdIsNull
}

public protocol Wallet {
    
    var provider: Provider { get }
    
    var address: String { get }
    
    func getAccountState(completion: @escaping (Swift.Result<AccountState, Error>) -> Void)
    
    func setSigningKey(fee: TransactionFee, nonce: UInt32?, oncahinAuth: Bool, timeRange: TimeRange, completion: @escaping (Swift.Result<String, Error>) -> Void)

    func transfer(to: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange, completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    func withdraw(ethAddress: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, fastProcessing: Bool, timeRange: TimeRange, completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    func forcedExit(target: String, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange, completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    var isSigningKeySet: Bool { get }
    
    func createEthereumProvider(web3: web3) throws -> EthereumProvider
    
    func buildSignedChangePubKeyTxOnchain(fee: TransactionFee,
                                          accountId: UInt32,
                                          nonce: UInt32,
                                          timeRange: TimeRange) -> Promise<SignedTransaction<ChangePubKey<ChangePubKeyOnchain>>>
    
    func buildSignedChangePubKeyTxSigned(fee: TransactionFee,
                                          accountId: UInt32,
                                          nonce: UInt32,
                                          timeRange: TimeRange) -> Promise<SignedTransaction<ChangePubKey<ChangePubKeyECDSA>>>
    
    func buildSignedForcedExitTx(target: String,
                                 tokenIdentifier: String,
                                 fee: BigUInt,
                                 accountId: UInt32,
                                 nonce: UInt32,
                                 timeRange: TimeRange) -> Promise<SignedTransaction<ForcedExit>>
    
    func buildSignedTransferTx(to: String,
                               tokenIdentifier: String,
                               amount: BigUInt,
                               fee: BigUInt,
                               accountId: UInt32,
                               nonce: UInt32,
                               timeRange: TimeRange) -> Promise<SignedTransaction<Transfer>>

    func buildSignedWithdrawTx(to: String,
                               tokenIdentifier: String,
                               amount: BigUInt,
                               fee: BigUInt,
                               accountId: UInt32,
                               nonce: UInt32,
                               timeRange: TimeRange) -> Promise<SignedTransaction<Withdraw>>
}


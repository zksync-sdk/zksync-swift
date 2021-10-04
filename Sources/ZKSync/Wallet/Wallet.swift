//
//  Wallet.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt
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

    func setSigningKey(fee: TransactionFee,
                       nonce: UInt32?,
                       onchainAuth: Bool,
                       timeRange: TimeRange,
                       completion: @escaping (Swift.Result<String, Error>) -> Void)

    // swiftlint:disable:next function_parameter_count
    func transfer(to: String,
                  amount: BigUInt,
                  fee: TransactionFee,
                  nonce: UInt32?,
                  timeRange: TimeRange,
                  completion: @escaping (Swift.Result<String, Error>) -> Void)

    // swiftlint:disable:next function_parameter_count
    func withdraw(ethAddress: String,
                  amount: BigUInt,
                  fee: TransactionFee,
                  nonce: UInt32?,
                  fastProcessing: Bool,
                  timeRange: TimeRange,
                  completion: @escaping (Swift.Result<String, Error>) -> Void)

    func forcedExit(target: String,
                    fee: TransactionFee,
                    nonce: UInt32?,
                    timeRange: TimeRange,
                    completion: @escaping (Swift.Result<String, Error>) -> Void)

    func mintNFT(recepient: String,
                 contentHash: String,
                 fee: TransactionFee,
                 nonce: UInt32?,
                 completion: @escaping (Swift.Result<String, Error>) -> Void)

    // swiftlint:disable:next function_parameter_count
    func withdrawNFT(to: String,
                     token: NFT,
                     fee: TransactionFee,
                     nonce: UInt32?,
                     timeRange: TimeRange,
                     completion: @escaping (Swift.Result<String, Error>) -> Void)

    // swiftlint:disable:next function_parameter_count
    func transferNFT(to: String,
                     token: NFT,
                     fee: TransactionFee,
                     nonce: UInt32?,
                     timeRange: TimeRange,
                     completion: @escaping (Swift.Result<[String], Error>) -> Void)

    // swiftlint:disable:next function_parameter_count
    func swap(order1: Order,
              order2: Order,
              amount1: BigUInt,
              amount2: BigUInt,
              fee: TransactionFee,
              nonce: UInt32?,
              completion: @escaping (Swift.Result<String, Error>) -> Void)

    // swiftlint:disable:next function_parameter_count
    func buildSignedOrder(recepient: String,
                          sell: Token,
                          buy: Token,
                          ratio: (BigUInt, BigUInt),
                          amount: BigUInt,
                          nonce: UInt32,
                          timeRange: TimeRange) throws -> Order

    var isSigningKeySet: Bool { get }

    func createEthereumProvider(web3: web3) throws -> EthereumProvider

    func enable2FA(completion: @escaping (ZKSyncResult<Toggle2FAInfo>) -> Void) throws

    func disable2FA(completion: @escaping (ZKSyncResult<Toggle2FAInfo>) -> Void) throws
}

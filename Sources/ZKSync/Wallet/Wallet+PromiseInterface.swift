//
//  Wallet+PromiseInterface.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 22/01/2021.
//

//import Foundation
//import PromiseKit
//import BigInt
//
//public extension Wallet {
//
//    func getAccountStatePromise() -> Promise<AccountState> {
//        return Promise {
//            self.getAccountState(completion: $0.resolve)
//        }
//    }
//
//    func setSigningKeyPromise(fee: TransactionFee,
//                              nonce: UInt32?,
//                              onchainAuth: Bool,
//                              timeRange: TimeRange = .max) -> Promise<String> {
//        return Promise {
//            self.setSigningKey(fee: fee,
//                               nonce: nonce,
//                               onchainAuth: onchainAuth,
//                               timeRange: timeRange,
//                               completion: $0.resolve)
//        }
//    }
//
//    func transferPromise(to: String,
//                         amount: BigUInt,
//                         fee: TransactionFee,
//                         nonce: UInt32?,
//                         timeRange: TimeRange = .max) -> Promise<String> {
//        return Promise {
//            self.transfer(to: to,
//                          amount: amount,
//                          fee: fee,
//                          nonce: nonce,
//                          timeRange: timeRange,
//                          completion: $0.resolve)
//        }
//    }
//
//    func withdrawPromise(ethAddress: String,
//                         amount: BigUInt,
//                         fee: TransactionFee,
//                         nonce: UInt32?,
//                         fastProcessing: Bool,
//                         timeRange: TimeRange = .max) -> Promise<String> {
//        return Promise {
//            self.withdraw(ethAddress: ethAddress,
//                          amount: amount,
//                          fee: fee,
//                          nonce: nonce,
//                          fastProcessing: fastProcessing,
//                          timeRange: timeRange,
//                          completion: $0.resolve)
//        }
//    }
//
//    func forcedExitPromise(target: String,
//                           fee: TransactionFee,
//                           nonce: UInt32?,
//                           timeRange: TimeRange = .max) -> Promise<String> {
//        return Promise {
//            self.forcedExit(target: target,
//                            fee: fee,
//                            nonce: nonce,
//                            timeRange: timeRange,
//                            completion: $0.resolve)
//        }
//    }
//
//    func mintNFT(recepient: String,
//                 contentHash: String,
//                 fee: TransactionFee,
//                 nonce: UInt32?) -> Promise<String> {
//        return Promise {
//            self.mintNFT(recepient: recepient,
//                         contentHash: contentHash,
//                         fee: fee,
//                         nonce: nonce,
//                         completion: $0.resolve)
//        }
//    }
//
//    func withdrawNFT(to: String,
//                     token: NFT,
//                     fee: TransactionFee,
//                     nonce: UInt32?,
//                     timeRange: TimeRange = .max) -> Promise<String> {
//        return Promise {
//            self.withdrawNFT(to: to,
//                             token: token,
//                             fee: fee,
//                             nonce: nonce,
//                             timeRange: timeRange,
//                             completion: $0.resolve)
//        }
//    }
//
//    func transferNFT(to: String,
//                     token: NFT,
//                     fee: TransactionFee,
//                     nonce: UInt32?,
//                     timeRange: TimeRange = .max) -> Promise<[String]> {
//        return Promise {
//            self.transferNFT(to: to,
//                             token: token,
//                             fee: fee,
//                             nonce: nonce,
//                             timeRange: timeRange,
//                             completion: $0.resolve)
//        }
//    }
//
//    // swiftlint:disable:next function_parameter_count
//    func swap(order1: Order,
//              order2: Order,
//              amount1: BigUInt,
//              amount2: BigUInt,
//              fee: TransactionFee,
//              nonce: UInt32?) -> Promise<String> {
//        return Promise {
//            self.swap(order1: order1,
//                      order2: order2,
//                      amount1: amount1,
//                      amount2: amount2,
//                      fee: fee,
//                      nonce: nonce,
//                      completion: $0.resolve)
//        }
//    }
//
//    func enable2FA() throws -> Promise<Toggle2FAInfo> {
//        return Promise { try enable2FA(completion: $0.resolve) }
//    }
//
//    func disable2FA() throws -> Promise<Toggle2FAInfo> {
//        return Promise { try disable2FA(completion: $0.resolve) }
//    }
//}

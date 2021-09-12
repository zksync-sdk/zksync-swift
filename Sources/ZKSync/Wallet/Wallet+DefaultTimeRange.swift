//
//  Wallet+DefaultTimeRange.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 24/03/2021.
//

import Foundation
import BigInt

public extension Wallet {
    
    func setSigningKey(fee: TransactionFee,
                       nonce: UInt32?,
                       onchainAuth: Bool,
                       completion: @escaping (Swift.Result<String, Error>) -> Void) {
        self.setSigningKey(fee: fee,
                           nonce: nonce,
                           onchainAuth: onchainAuth,
                           timeRange: .max,
                           completion: completion)
    }

    func transfer(to: String,
                  amount: BigUInt,
                  fee: TransactionFee,
                  nonce: UInt32?,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) {
        self.transfer(to: to,
                      amount: amount,
                      fee: fee,
                      nonce: nonce,
                      timeRange: .max,
                      completion: completion)
    }
    
    func withdraw(ethAddress: String,
                  amount: BigUInt,
                  fee: TransactionFee,
                  nonce: UInt32?,
                  fastProcessing: Bool,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) {
        self.withdraw(ethAddress: ethAddress,
                      amount: amount,
                      fee: fee,
                      nonce: nonce,
                      fastProcessing: fastProcessing,
                      timeRange: .max,
                      completion: completion)
    }
    
    func forcedExit(target: String,
                    fee: TransactionFee,
                    nonce: UInt32?,
                    completion: @escaping (Swift.Result<String, Error>) -> Void) {
        self.forcedExit(target: target,
                        fee: fee,
                        nonce: nonce,
                        timeRange: .max,
                        completion: completion)
    }
    
    func withdrawNFT(to: String,
                     token: NFT,
                     fee: TransactionFee,
                     nonce: UInt32?,
                     completion: @escaping (Swift.Result<String, Error>) -> Void) {
        self.withdrawNFT(to: to,
                         token: token,
                         fee: fee,
                         nonce: nonce,
                         timeRange: .max,
                         completion: completion)
    }
    
    func transferNFT(to: String,
                     token: NFT,
                     fee: TransactionFee,
                     nonce: UInt32?,
                     completion: @escaping (Swift.Result<[String], Error>) -> Void) {
        self.transferNFT(to: to,
                         token: token,
                         fee: fee,
                         nonce: nonce,
                         timeRange: .max,
                         completion: completion)
    }
}

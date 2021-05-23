//
//  Wallet+PromiseInterface.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 22/01/2021.
//

import Foundation
import PromiseKit
import BigInt

public extension Wallet {
    func getAccountStatePromise() -> Promise<AccountState> {
        return Promise { self.getAccountState(completion: $0.resolve) }
    }
    
    func setSigningKeyPromise(fee: TransactionFee, nonce: UInt32?, oncahinAuth: Bool, timeRange: TimeRange = .max
    ) -> Promise<String> {
        return Promise { self.setSigningKey(fee: fee, nonce: nonce, oncahinAuth: oncahinAuth, timeRange: timeRange, completion: $0.resolve) }
    }
    
    func transferPromise(to: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange = .max) -> Promise<String> {
        return Promise { self.transfer(to: to, amount: amount, fee: fee, nonce: nonce, timeRange: timeRange, completion: $0.resolve) }
    }
    
    func withdrawPromise(ethAddress: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, fastProcessing: Bool, timeRange: TimeRange = .max) -> Promise<String> {
        return Promise { self.withdraw(ethAddress: ethAddress, amount: amount, fee: fee, nonce: nonce, fastProcessing: fastProcessing, timeRange: timeRange, completion: $0.resolve ) }
    }
    
    func forcedExitPromise(target: String, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange = .max) -> Promise<String> {
        return Promise { self.forcedExit(target: target, fee: fee, nonce: nonce, timeRange: timeRange, completion: $0.resolve) }
    }
    
    func mintNFT(recepient: String, contentHash: String, fee: TransactionFee, nonce: UInt32?) -> Promise<String> {
        return Promise { self.mintNFT(recepient: recepient, contentHash: contentHash, fee: fee, nonce: nonce, completion: $0.resolve) }
    }
    
    func withdrawNFT(to: String, token: NFT, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange = .max) -> Promise<String> {
        return Promise { self.withdrawNFT(to: to, token: token, fee: fee, nonce: nonce, timeRange: timeRange, completion: $0.resolve) }
    }
    
    func transferNFT(to: String, token: NFT, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange) -> Promise<[String]> {
        return Promise { self.transferNFT(to: to, token: token, fee: fee, nonce: nonce, timeRange: timeRange, completion: $0.resolve) }
    }
    
    func swap(fee: TransactionFee, nonce: UInt32?) -> Promise<String> {
        return Promise { self.swap(fee: fee, nonce: nonce, completion: $0.resolve) }
    }
}

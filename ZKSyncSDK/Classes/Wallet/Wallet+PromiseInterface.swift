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
    
    func getTransactionFeePromise(for transactionType: TransactionType, tokenIdentifier: String) -> Promise<TransactionFeeDetails> {
        return Promise { self.getTransactionFee(for: transactionType, tokenIdentifier: tokenIdentifier, completion: $0.resolve) }
    }
    
    func getTransactionFeePromise(for transactionType: TransactionType, address: String, tokenIdentifier: String) -> Promise<TransactionFeeDetails> {
        return Promise { self.getTransactionFee(for: transactionType, address: address, tokenIdentifier: tokenIdentifier, completion: $0.resolve) }
    }
    
    func getTransactionFeePromise(for batchRequest: TransactionFeeBatchRequest) -> Promise<TransactionFeeDetails> {
        return Promise { self.getTransactionFee(for: batchRequest, completion: $0.resolve) }
    }
    
    func setSigningKeyPromise(fee: TransactionFee, nonce: UInt32?, oncahinAuth: Bool) -> Promise<String> {
        return Promise { self.setSigningKey(fee: fee, nonce: nonce, oncahinAuth: oncahinAuth, completion: $0.resolve) }
    }
    
    func transferPromise(to: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?) -> Promise<String> {
        return Promise { self.transfer(to: to, amount: amount, fee: fee, nonce: nonce, completion: $0.resolve) }
    }
    
    func withdrawPromise(ethAddress: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, fastProcessing: Bool) -> Promise<String> {
        return Promise { self.withdraw(ethAddress: ethAddress, amount: amount, fee: fee, nonce: nonce, fastProcessing: fastProcessing, completion: $0.resolve ) }
    }
    
    func forcedExitPromise(target: String, fee: TransactionFee, nonce: UInt32?) -> Promise<String> {
        return Promise { self.forcedExit(target: target, fee: fee, nonce: nonce, completion: $0.resolve) }
    }
}

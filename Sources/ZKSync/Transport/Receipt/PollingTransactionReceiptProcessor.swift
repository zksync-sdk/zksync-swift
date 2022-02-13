//
//  PollingTransactionReceiptProcessor.swift
//  ZKSync
//
//  Created by Maxim Makhun on 7/14/21.
//

import Foundation
import PromiseKit

/// Helper class, which allows to wait until transaction is completed.
public class PollingTransactionReceiptProcessor {

    /// Time interval between polls.
    public let pollInterval: DispatchTimeInterval

    /// Amount of attempts, which will be used by `PollingTransactionReceiptProcessor` to verify whether
    /// transaction was commited or not.
    public let attempts: Int

    let provider: Provider

    let semaphore = DispatchSemaphore(value: 0)

    /// Initializer, which allows to create `PollingTransactionReceiptProcessor` instance, based on `Provider` instance.
    /// - Parameters:
    ///   - provider: Provider instance.
    ///   - pollInterval: Time interval between polls.
    ///   - attempts: Amount of attempts.
    public init(_ provider: Provider,
                pollInterval: DispatchTimeInterval = .milliseconds(100),
                attempts: Int = .max) {
        self.provider = provider
        self.pollInterval = pollInterval
        self.attempts = attempts
    }

    /// Method, which allows to wait till transaction is completed.
    /// - Parameters:
    ///   - txHash: Hash of transaction.
    ///   - transactionStatus: Transaction status.
    /// - Returns: Promise, which contains `TransactionDetails`.
    public func waitForTransaction(_ txHash: String,
                                   transactionStatus: TransactionStatus) -> Promise<TransactionDetails> {
        return Promise<TransactionDetails> { seal in
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }

                for _ in 0...self.attempts {
                    self.provider.transactionDetails(txHash: txHash) { (result) in
                        switch result {
                        case .success(let transactionDetails):
                            if !transactionDetails.executed {
                                DispatchQueue.global().asyncAfter(deadline: .now() + self.pollInterval) {
                                    self.semaphore.signal()
                                }
                            } else {
                                switch transactionStatus {
                                case .sent:
                                    seal.fulfill(transactionDetails)
                                case .commited:
                                    if let block = transactionDetails.block, block.committed {
                                        seal.fulfill(transactionDetails)
                                    }
                                case .verified:
                                    if let block = transactionDetails.block, block.verified {
                                        seal.fulfill(transactionDetails)
                                    }
                                }
                            }
                        case .failure(let error):
                            seal.reject(error)
                        }
                    }

                    self.semaphore.wait()
                }
            }
        }
    }
}

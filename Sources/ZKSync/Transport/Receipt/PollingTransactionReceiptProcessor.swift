//
//  PollingTransactionReceiptProcessor.swift
//  ZKSync
//
//  Created by Maxim Makhun on 7/14/21.
//

import Foundation
import PromiseKit

public class PollingTransactionReceiptProcessor {
    
    let provider: Provider
    
    let sleepDuration: Double
    
    let attempts: Int
    
    let semaphore = DispatchSemaphore(value: 0)
    
    public init(_ provider: Provider, sleepDuration: Double, attempts: Int) {
        self.provider = provider
        self.sleepDuration = sleepDuration
        self.attempts = attempts
    }
    
    public init(_ wallet: Wallet, sleepDuration: Double, attempts: Int) {
        self.provider = wallet.provider
        self.sleepDuration = sleepDuration
        self.attempts = attempts
    }
    
    public func waitForTransaction(_ txHash: String, transactionStatus: TransactionStatus) -> Promise<TransactionDetails> {
        return Promise<TransactionDetails> { seal in
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                
                for _ in 0...self.attempts {
                    self.provider.transactionDetails(txHash: txHash) { (result) in
                        switch result {
                        case .success(let transactionDetails):
                            if !transactionDetails.executed {
                                DispatchQueue.global().asyncAfter(deadline: .now() + self.sleepDuration) {
                                    self.semaphore.signal()
                                }
                            } else {
                                switch transactionStatus {
                                case .sent:
                                    seal.fulfill(transactionDetails)
                                    break
                                    
                                case .commited:
                                    if transactionDetails.block.committed {
                                        seal.fulfill(transactionDetails)
                                    }
                                    break
                                    
                                case .verified:
                                    if transactionDetails.block.verified {
                                        seal.fulfill(transactionDetails)
                                    }
                                    break
                                }
                            }
                            
                            break
                        case .failure(let error):
                            seal.reject(error)
                            break
                        }
                    }
                    
                    self.semaphore.wait()
                }
            }
        }
    }
}

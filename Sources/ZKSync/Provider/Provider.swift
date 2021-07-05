//
//  Provider.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

public protocol Provider {
    
    func accountState(address: String,
                      queue: DispatchQueue,
                      completion: @escaping (ZKSyncResult<AccountState>) -> Void)
    
    func transactionFee(request: TransactionFeeRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void)
    
    func transactionFee(request: TransactionFeeBatchRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void)
    
    func tokens(completion: @escaping (ZKSyncResult<Tokens>) -> Void)
    
    func tokenPrice(token: Token, completion: @escaping (ZKSyncResult<Decimal>) -> Void)
    
    func contractAddress(queue: DispatchQueue, completion: @escaping (ZKSyncResult<ContractAddress>) -> Void)
    
    func submitTx(_ tx: ZkSyncTransaction,
                  ethereumSignature: EthSignature?,
                  fastProcessing: Bool,
                  completion: @escaping (ZKSyncResult<String>) -> Void)
        
    func submitTxBatch(txs: [TransactionSignaturePair],
                       ethereumSignature: EthSignature?,
                       completion: @escaping (ZKSyncResult<[String]>) -> Void)
        
    func transactionDetails(txHash: String,
                            completion: @escaping (ZKSyncResult<TransactionDetails>) -> Void)
    
    func ethOpInfo(priority: Int,
                   completion: @escaping (ZKSyncResult<EthOpInfo>) -> Void)
    
    func confirmationsForEthOpAmount(completion: @escaping (ZKSyncResult<UInt64>) -> Void)
    
    func ethTxForWithdrawal(withdrawalHash: String, completion: @escaping (ZKSyncResult<String>) -> Void)
}

public extension Provider {
    
    func accountState(address: String, completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        self.accountState(address: address, queue: .main, completion: completion)
    }

    func transactionFee(for transactionType:TransactionType,
                        address: String,
                        tokenIdentifier: String,
                        completion: @escaping ZKSyncCompletion<TransactionFeeDetails>) {
        let request = TransactionFeeRequest(transactionType: transactionType,
                                            address: address,
                                            tokenIdentifier: tokenIdentifier)
        self.transactionFee(request: request, completion: completion)
    }
    
    func contractAddress(completion: @escaping (ZKSyncResult<ContractAddress>) -> Void) {
        self.contractAddress(queue: .main, completion: completion)
    }
    
    func submitTx(_ tx: ZkSyncTransaction,
                  fastProcessing: Bool,
                  completion: @escaping (ZKSyncResult<String>) -> Void) {
        self.submitTx(tx,
                      ethereumSignature: nil,
                      fastProcessing: fastProcessing,
                      completion: completion)
    }
    
    func submitTxBatch(txs: [TransactionSignaturePair],
                       completion: @escaping (ZKSyncResult<[String]>) -> Void) {
        self.submitTxBatch(txs: txs, ethereumSignature: nil, completion: completion)
    }
}

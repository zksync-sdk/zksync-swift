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
                      completion: @escaping (ZKSyncResult<AccountState>) -> Void)
    
    func transactionFee(request: TransactionFeeRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void)
    
    func transactionFee(request: TransactionFeeBatchRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void)

    func tokens(completion: @escaping (ZKSyncResult<Tokens>) -> Void)

    func tokenPrice(token: Token, completion: @escaping (ZKSyncResult<Decimal>) -> Void)
    
    func contractAddress(completion: @escaping (ZKSyncResult<ContractAddress>) -> Void)
    
    func submitTx<TX: ZkSyncTransaction>(_ tx: TX,
                                         ethereumSignature: EthSignature?,
                                         fastProcessing: Bool,
                                         completion: @escaping (ZKSyncResult<String>) -> Void)
    
    func submitTx<TX: ZkSyncTransaction>(_ tx: TX,
                                         fastProcessing: Bool,
                                         completion: @escaping (ZKSyncResult<String>) -> Void)
}

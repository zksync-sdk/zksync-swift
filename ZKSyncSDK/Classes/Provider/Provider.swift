//
//  Provider.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

public protocol Provider {
    func accountInfo(address: String,
                     completion: @escaping (ZKSyncResult<AccountState>) -> Void)
    
    func contractAddress(completion: @escaping (ZKSyncResult<ContractAddress>) -> Void)

    func tokenPrice(token: Token, completion: @escaping (ZKSyncResult<Decimal>) -> Void)
    
    func transactionFee(request: TransactionFeeRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void)
    
    func transactionFee(request: TransactionFeeBatchRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void)

}

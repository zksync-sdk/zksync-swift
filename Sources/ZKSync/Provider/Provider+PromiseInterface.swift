//
//  Provider+PromiseInterface.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 29/01/2021.
//

import Foundation
import PromiseKit

public extension Provider {
    
    func accountStatePromise(address: String,
                             queue: DispatchQueue) -> Promise<AccountState> {
        return Promise { accountState(address: address, queue: queue, completion:  $0.resolve) }
    }
    
    func accountState(address: String) -> Promise<AccountState> {
        return Promise { accountState(address: address, completion: $0.resolve) }
    }
    
    func transactionFeePromise(request: TransactionFeeRequest) -> Promise<TransactionFeeDetails> {
        return Promise { transactionFee(request: request, completion: $0.resolve) }
    }

    func transactionFeePromise(request: TransactionFeeBatchRequest) -> Promise<TransactionFeeDetails> {
        return Promise { transactionFee(request: request, completion: $0.resolve) }
    }
    
    func transactionFeePromise(for transactionType:TransactionType,
                               address: String,
                               tokenIdentifier: String) -> Promise<TransactionFeeDetails> {
        return Promise { transactionFee(for: transactionType, address: address, tokenIdentifier: tokenIdentifier, completion: $0.resolve) }
    }
    
    func tokensPromise() -> Promise<Tokens> {
        return Promise { tokens(completion: $0.resolve) }
    }

    func tokenPricePromise(token: Token) -> Promise<Decimal> {
        return Promise { tokenPrice(token: token, completion: $0.resolve) }
    }

    func contractAddressPromise(queue: DispatchQueue) -> Promise<ContractAddress> {
        return Promise { contractAddress(queue: queue, completion: $0.resolve) }
    }
    
    func contractAddressPromise() -> Promise<ContractAddress> {
        return Promise { contractAddress(completion: $0.resolve) }
    }

    func submitTxPromise(_ tx: ZkSyncTransaction,
                  ethereumSignature: EthSignature?,
                  fastProcessing: Bool) -> Promise<String> {
        return Promise { submitTx(tx, ethereumSignature: ethereumSignature, fastProcessing: fastProcessing, completion: $0.resolve) }
    }
    
    func submitTxPromise(_ tx: ZkSyncTransaction,
                  fastProcessing: Bool) -> Promise<String> {
        return Promise { submitTx(tx, fastProcessing: fastProcessing, completion: $0.resolve) }
    }

    func submitTxBatchPromise(txs: [TransactionSignaturePair],
                       ethereumSignature: EthSignature?) -> Promise<[String]> {
        return Promise { submitTxBatch(txs: txs, ethereumSignature: ethereumSignature, completion: $0.resolve) }
    }
    
    func submitTxBatchPromise(txs: [TransactionSignaturePair]) -> Promise<[String]> {
        return Promise { submitTxBatch(txs: txs, completion: $0.resolve )}
    }

    func transactionDetailsPromise(txHash: String) -> Promise<TransactionDetails> {
        return Promise { transactionDetails(txHash: txHash, completion: $0.resolve) }
    }

    func ethOpInfo(priority: Int) -> Promise<EthOpInfo> {
        return Promise { ethOpInfo(priority: priority, completion: $0.resolve) }
    }

    func confirmationsForEthOpAmount() ->Promise <UInt64> {
        return Promise { confirmationsForEthOpAmount(completion: $0.resolve) }
    }

    func ethTxForWithdrawal(withdrawalHash: String) -> Promise<String> {
        return Promise { ethTxForWithdrawal(withdrawalHash: withdrawalHash, completion: $0.resolve) }
    }
}

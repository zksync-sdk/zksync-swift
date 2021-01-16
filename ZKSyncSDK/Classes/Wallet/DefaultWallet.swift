//
//  DefaultWallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt
import PromiseKit

enum DefaultWalletError: Error {
    case internalError
}

public class DefaultWallet: Wallet {
    
    private let group = DispatchGroup()
    private let deliveryQueue = DispatchQueue(label: "com.zksyncsdk.wallet")
    
    public let provider: Provider
    internal let ethSigner: EthSigner
    internal let zkSigner: ZkSigner
    
    internal var accountId: Int32 = 0
    internal var pubKeyHash: String = ""
    
    public convenience init(ethSigner: EthSigner, zkSigner: ZkSigner, transport: Transport) throws {
        try self.init(ethSigner: ethSigner, zkSigner: zkSigner, provider: DefaultProvider(transport: transport))
    }

    public init(ethSigner: EthSigner, zkSigner: ZkSigner, provider: Provider) throws {
        self.provider = provider
        self.ethSigner = ethSigner
        self.zkSigner = zkSigner
        
        let accountState = try self.getAccountStateSync()
        
        self.accountId = accountState.id
        self.pubKeyHash = accountState.committed.pubKeyHash
    }

    public func getContractAddress(completion: @escaping (Swift.Result<ContractAddress, Error>) -> Void) {
        self.provider.contractAddress(completion: completion)
    }
    
    public func getAccountState(completion: @escaping (Swift.Result<AccountState, Error>) -> Void) {
        self.getAccountState(queue: .main, completion: completion)
    }

    private func getAccountState(queue: DispatchQueue, completion: @escaping (Swift.Result<AccountState, Error>) -> Void) {
        self.provider.accountState(address: self.ethSigner.address, queue: queue, completion: completion)
    }

    public func getTokenPrice(completion: @escaping (Swift.Result<Decimal, Error>) -> Void) {
        self.provider.tokenPrice(token: Token.ETH, completion: completion)
    }

    public func getTransactionFee(for transactionType:TransactionType,
                                  tokenIdentifier: String,
                                  completion: @escaping ZKSyncCompletion<TransactionFeeDetails>) {
        self.getTransactionFee(for: transactionType,
                               address: ethSigner.address,
                               tokenIdentifier: tokenIdentifier,
                               completion: completion)
    }
    
    public func getTransactionFee(for transactionType:TransactionType,
                                  address: String,
                                  tokenIdentifier: String,
                                  completion: @escaping ZKSyncCompletion<TransactionFeeDetails>) {
        let request = TransactionFeeRequest(transactionType: transactionType,
                                            address: address,
                                            tokenIdentifier: tokenIdentifier)
        self.provider.transactionFee(request: request, completion: completion)
    }
    
    public func getTransactionFee(for batchRequest: TransactionFeeBatchRequest,
                           completion: @escaping ZKSyncCompletion<TransactionFeeDetails>) {
        self.provider.transactionFee(request: batchRequest, completion: completion)
    }
    
    internal func submitSignedTransaction<TX: ZkSyncTransaction>(_ transaction: TX,
                                                                ethereumSignature: EthSignature?,
                                                                fastProcessing: Bool,
                                                                completion: @escaping (ZKSyncResult<String>) -> Void) {
        provider.submitTx(transaction,
                          ethereumSignature: ethereumSignature,
                          fastProcessing: fastProcessing,
                          completion: completion)
    }
    
    internal func getNonce(completion: @escaping (Swift.Result<Int32, Error>) -> Void) {
        self.getAccountState { (result) in
            completion(Swift.Result {
                try result.get().committed.nonce
            })
        }
    }
    
    private func getAccountStateSync() throws -> AccountState {
        
        var callResult: Swift.Result<AccountState, Error>? = nil
        self.group.enter()
        self.getAccountState(queue: self.deliveryQueue) { (result) in
            callResult = result
            self.group.leave()
        }
        self.group.wait()
        
        guard let r = callResult else {
            throw DefaultWalletError.internalError
        }
        return try r.get()
    }

}

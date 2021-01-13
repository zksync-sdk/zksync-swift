//
//  DefaultWallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt

public class DefaultWallet: Wallet {
    
    public let provider: Provider
    private let ethSigner: EthSigner
    private let zkSigner: ZkSigner
    
    public convenience init(ethSigner: EthSigner, zkSigner: ZkSigner, transport: Transport) {
        self.init(ethSigner: ethSigner, zkSigner: zkSigner, provider: DefaultProvider(transport: transport))
    }

    public init(ethSigner: EthSigner, zkSigner: ZkSigner, provider: Provider) {
        self.provider = provider
        self.ethSigner = ethSigner
        self.zkSigner = zkSigner
    }

    public func getContractAddress(completion: @escaping (Result<ContractAddress, Error>) -> Void) {
        self.provider.contractAddress(completion: completion)
    }
    
    public func getAccountState(completion: @escaping (Result<AccountState, Error>) -> Void) {
        self.provider.accountState(address: self.ethSigner.address, completion: completion)
    }
    
    public func getTokenPrice(completion: @escaping (Result<Decimal, Error>) -> Void) {
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
    
//    public func setSigningKey(fee: Transa, nonce: Int32, onchainAuth: Bool, completion: @escaping ZKSynCompletion<Void>) {
//        self.ethSigner.
//    }
}

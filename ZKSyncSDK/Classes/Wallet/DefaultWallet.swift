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
    
    private let accountId: Int32 = 0
    
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

//    @Override
//    public String syncTransfer(String to, BigInteger amount, TransactionFee fee, Integer nonce) {
//
//        final Integer nonceToUse = nonce == null ? getNonce() : nonce;
//
//        final SignedTransaction<Transfer> signedTransfer = buildSignedTransferTx(to , fee.getFeeToken(), amount, fee.getFee(), nonceToUse);
//
//        return submitSignedTransaction(signedTransfer.getTransaction(), signedTransfer.getEthereumSignature(), false);
//    }

    public func transfer(to: String, amount: BigUInt, fee: TransactionFee, nonce: Int32?, completion: @escaping (Result<String, Error>) -> Void) {

        guard let nonceToUse = nonce else {
            self.getNonce { (result) in
                switch result {
                case .success(let nonceToUse):
                    self.transfer(to: to, amount: amount, fee: fee, nonce: nonceToUse, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
        
        buildSignedTransferTx(to: to, tokenIdentifier: fee.feeToken, amount: amount, fee: fee.fee, nonce: nonceToUse) { (result) in
            switch result {
            case .success(let signedTransaction):
                self.submitSignedTransaction(signedTransaction.transaction,
                                             ethereumSignature: signedTransaction.ethereumSignature,
                                             fastProcessing: false, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    

    func buildSignedTransferTx(to: String,
                               tokenIdentifier: String,
                               amount: BigUInt,
                               fee: BigUInt,
                               nonce: Int32,
                               completion: @escaping (Result<SignedTransaction<Transfer>, Error>) -> Void) {
        
        provider.tokens { (result) in

            completion(Result {
                let token = try result.get().tokenByTokenIdentifier(tokenIdentifier)
                let transfer = Transfer(accountId: self.accountId,
                                        from: self.ethSigner.address,
                                        to: to,
                                        token: token.id,
                                        amount: amount,
                                        fee: fee.description,
                                        nonce: nonce)
                let ethSignature = try self.ethSigner.signTransfer(to: to, accountId: self.accountId, nonce: nonce, amount: amount, token: token, fee: fee)
                let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(transfer: transfer), ethereumSignature: ethSignature)
                return signedTransaction
            })
        }
    }
    
//    private String submitSignedTransaction(ZkSyncTransaction signedTransaction,
//                                         EthSignature ethereumSignature,
//                                         boolean fastProcessing) {
//        return provider.submitTx(signedTransaction, ethereumSignature, fastProcessing);
//    }
    
    
    private func submitSignedTransaction<TX: ZkSyncTransaction>(_ transaction: TX,
                                                                ethereumSignature: EthSignature,
                                                                fastProcessing: Bool,
                                                                completion: @escaping (ZKSyncResult<String>) -> Void) {
        provider.submitTx(transaction,
                          ethereumSignature: ethereumSignature,
                          fastProcessing: fastProcessing,
                          completion: completion)
    }
    
    private func getNonce(completion: @escaping (Result<Int32, Error>) -> Void) {
        self.getAccountState { (result) in
            completion(Result {
                try result.get().committed.nonce
            })
        }
    }

}

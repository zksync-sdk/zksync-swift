//
//  DefaultWallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt

enum DefaultWalletError: Error {
    case internalError
}

public class DefaultWallet: Wallet {
    
    private let group = DispatchGroup()
    private let deliveryQueue = DispatchQueue(label: "com.zksyncsdk.wallet")
    
    public let provider: Provider
    private let ethSigner: EthSigner
    private let zkSigner: ZkSigner
    
    private var accountId: Int32 = 0
    private var pubKeyHash: String = ""
    
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

    public func getContractAddress(completion: @escaping (Result<ContractAddress, Error>) -> Void) {
        self.provider.contractAddress(completion: completion)
    }
    
    public func getAccountState(completion: @escaping (Result<AccountState, Error>) -> Void) {
        self.getAccountState(queue: .main, completion: completion)
    }

    private func getAccountState(queue: DispatchQueue, completion: @escaping (Result<AccountState, Error>) -> Void) {
        self.provider.accountState(address: self.ethSigner.address, queue: queue, completion: completion)
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
    
    public func withdraw(ethAddress: String, amount: BigUInt, fee: TransactionFee, nonce: Int32?, fastProcessing: Bool, completion: @escaping (Result<String, Error>) -> Void) {

        guard let nonceToUse = nonce else {
            self.getNonce { (result) in
                switch result {
                case .success(let nonceToUse):
                    self.withdraw(ethAddress: ethAddress, amount: amount, fee: fee, nonce: nonceToUse, fastProcessing: fastProcessing, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
        
        buildSignedWithdrawTx(to: ethAddress, tokenIdentifier: fee.feeToken, amount: amount, fee: fee.fee, nonce: nonceToUse) { (result) in
            switch result {
            case .success(let signedTransaction):
                self.submitSignedTransaction(signedTransaction.transaction,
                                             ethereumSignature: signedTransaction.ethereumSignature,
                                             fastProcessing: fastProcessing, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func forcedExit(target: String, fee: TransactionFee, nonce: Int32?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let nonceToUse = nonce else {
            self.getNonce { (result) in
                switch result {
                case .success(let nonceToUse):
                    self.forcedExit(target: target, fee: fee, nonce: nonceToUse, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
        
        buildSignedForcedExitTx(target: target, tokenIdentifier: fee.feeToken, fee: fee.fee, nonce: nonceToUse) { (result) in
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

    func buildSignedWithdrawTx(to: String,
                               tokenIdentifier: String,
                               amount: BigUInt,
                               fee: BigUInt,
                               nonce: Int32,
                               completion: @escaping (Result<SignedTransaction<Withdraw>, Error>) -> Void) {
        
        provider.tokens { (result) in

            completion(Result {
                let token = try result.get().tokenByTokenIdentifier(tokenIdentifier)
                let withdraw = Withdraw(accountId: self.accountId,
                                        from: self.ethSigner.address,
                                        to: to,
                                        token: token.id,
                                        amount: amount,
                                        fee: fee.description,
                                        nonce: nonce)
                let ethSignature = try self.ethSigner.signWithdraw(to: to, accountId: self.accountId, nonce: nonce, amount: amount, token: token, fee: fee)
                let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(withdraw: withdraw), ethereumSignature: ethSignature)
                return signedTransaction
            })
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
    
    func buildSignedForcedExitTx(target: String,
                                 tokenIdentifier: String,
                                 fee: BigUInt,
                                 nonce: Int32,
                                 completion: @escaping (Result<SignedTransaction<ForcedExit>, Error>) -> Void) {
        
        provider.tokens { (result) in

            completion(Result {
                let token = try result.get().tokenByTokenIdentifier(tokenIdentifier)
                let forcedExit = ForcedExit(initiatorAccountId: self.accountId,
                                            target: target,
                                            token: token.id,
                                            fee: fee.description,
                                            nonce: nonce)
                let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(forcedExit: forcedExit), ethereumSignature: nil)
                return signedTransaction
            })
        }
    }
    
    private func submitSignedTransaction<TX: ZkSyncTransaction>(_ transaction: TX,
                                                                ethereumSignature: EthSignature?,
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
    
    private func getAccountStateSync() throws -> AccountState {
        
        var callResult: Result<AccountState, Error>? = nil
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

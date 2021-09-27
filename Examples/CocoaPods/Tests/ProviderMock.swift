//
//  ProviderMock.swift
//  ZKSyncExample
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

enum ProviderMockError: Error {
    case error
}

class ProviderMock: Provider {

    let accountState: AccountState
    let expectedSignature: EthSignature?
    var received: ZkSyncTransaction?
    let tokens: Tokens?

    init(accountState: AccountState, expectedSignature: EthSignature? = nil, tokens: Tokens? = nil) {
        self.accountState = accountState
        self.expectedSignature = expectedSignature
        self.tokens = tokens
    }

    func accountState(address: String, completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        self.accountState(address: address, queue: .main, completion: completion)
    }

    func accountState(address: String,
                      queue: DispatchQueue,
                      completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        queue.async {
            completion(.success(self.accountState))
        }
    }

    func transactionFee(request: TransactionFeeRequest,
                        completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void) {
    }

    func transactionFee(request: TransactionFeeBatchRequest,
                        completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void) {
    }

    func tokens(completion: @escaping (ZKSyncResult<Tokens>) -> Void) {
        guard let tokens = self.tokens else {
            let token = Token(id: 0,
                              address: "0x0000000000000000000000000000000000000000",
                              symbol: "ETH",
                              decimals: 0)
            let tokens = Tokens(tokens: [token.address: token])
            completion(.success(tokens))
            return
        }
        completion(.success(tokens))
    }

    func tokenPrice(token: Token, completion: @escaping (ZKSyncResult<Decimal>) -> Void) {
    }

    func contractAddress(completion: @escaping (ZKSyncResult<ContractAddress>) -> Void) {
    }

    func contractAddress(queue: DispatchQueue, completion: @escaping (ZKSyncResult<ContractAddress>) -> Void) {
    }

    // swiftlint:disable:next identifier_name
    func submitTx<TX>(_ tx: TX,
                      ethereumSignature: EthSignature?,
                      fastProcessing: Bool,
                      completion: @escaping (ZKSyncResult<String>) -> Void) where TX: ZkSyncTransaction {
        received = tx
        if ethereumSignature?.signature == self.expectedSignature?.signature,
           ethereumSignature?.type == self.expectedSignature?.type {
            completion(.success("success:hash"))
        } else {
            completion(.failure(ProviderMockError.error))
        }
    }

    func submitTxBatch(txs: [TransactionSignaturePair],
                       ethereumSignature: EthSignature?,
                       completion: @escaping (ZKSyncResult<[String]>) -> Void) {

    }

    func submitTxBatch(txs: [TransactionSignaturePair], completion: @escaping (ZKSyncResult<[String]>) -> Void) {

    }

    func transactionDetails(txHash: String, completion: @escaping (ZKSyncResult<TransactionDetails>) -> Void) {

    }

    func ethOpInfo(priority: Int, completion: @escaping (ZKSyncResult<EthOpInfo>) -> Void) {

    }

    func confirmationsForEthOpAmount(completion: @escaping (ZKSyncResult<UInt64>) -> Void) {

    }

    func ethTxForWithdrawal(withdrawalHash: String, completion: @escaping (ZKSyncResult<String>) -> Void) {

    }

    func toggle2FA(toggle2FA: Toggle2FA, completion: @escaping (ZKSyncResult<Toggle2FAInfo>) -> Void) {

    }
}

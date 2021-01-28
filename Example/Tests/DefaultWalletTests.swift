//
//  DefaultWalletTests.swift
//  ZKSyncSDK_Tests
//
//  Created by Eugene Belyakov on 20/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import BigInt
@testable import ZKSyncSwift

class DefaultWalletTests: XCTestCase {

    static let EthPrivateKey = "0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";
    
    var zkSigner: ZkSigner!
    var ethSigner: EthSigner!
    var wallet: DefaultWallet!
    
    override func setUpWithError() throws {
        ethSigner = try DefaultEthSigner(privateKey: DefaultWalletTests.EthPrivateKey)
        zkSigner = try ZkSigner(ethSigner: ethSigner, chainId: .mainnet)
        let provider = MockProvider(accountState: defaultAccountState(accountId: 44))
        wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)
    }

    override func tearDownWithError() throws {
        zkSigner = nil
        ethSigner = nil
        wallet = nil
    }

    func testSetSigningKey() throws {
        let ethSignature = EthSignature(signature: "0xe062aca0dd8438174f424a26f3dd528ca9bd98366b2dafd6c6735eeaccd9e787245ac7dbbe2a37e3a74f168e723c5a2c613de25795a056bc81ff4c8d4106e56f1c", type: .ethereumSignature)

        let provider = MockProvider(accountState: defaultAccountState(accountId: 55),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)
        
        let exp = expectation(description: "setSigningKey")
        var result: Result<String, Error>?
        wallet.setSigningKey(fee: defaultTransactionFee(amount: 1000000000), nonce: 13, oncahinAuth: false) {
            result = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), "success:hash")
    }

    func testTransfer() throws {
        let ethSignature = EthSignature(signature: "0x6f7e631024b648e8d3984f84aa14d4f1b1013191042ef51b6443e3f25b075a0346988ab824687041ce699a91ed6e20bedff7c730aac3d8c7a111dd408c1862e41c", type: .ethereumSignature)

        let provider = MockProvider(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)
        
        let exp = expectation(description: "transfer")
        var result: Result<String, Error>?
        wallet.transfer(to: "0x19aa2ed8712072e918632259780e587698ef58df",
                        amount: 1000000000000,
                        fee: defaultTransactionFee(amount: 1000000),
                        nonce: 12) {
            result = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), "success:hash")
    }

    func testWithdraw() throws {
        let ethSignature = EthSignature(signature: "0xaa6ea9d9b06457c2652f80707b7ab35ba3b5b4ef593624773d00660dd5f9174215b327be358c9bd2ae539ae5220d47033d252506119a46cd898b42ae2bb366891c", type: .ethereumSignature)

        let provider = MockProvider(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)
        
        let exp = expectation(description: "withdraw")
        var result: Result<String, Error>?
        wallet.withdraw(ethAddress: "0x19aa2ed8712072e918632259780e587698ef58df",
                        amount: 1000000000000,
                        fee: defaultTransactionFee(amount: 1000000),
                        nonce: 12,
                        fastProcessing: false) {
            result = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), "success:hash")
    }

    func testForcedExit() throws {
        let exp = expectation(description: "forcedExit")
        var result: Result<String, Error>?

        wallet.forcedExit(target: "0x19aa2ed8712072e918632259780e587698ef58df",
                          fee: defaultTransactionFee(amount: 1000000),
                          nonce: 12) {
            result = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), "success:hash")
    }

    func testGetState() throws {
        let provider = MockProvider(accountState: defaultAccountState(accountId: 44))
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)
        
        let exp = expectation(description: "getState")
        var result: Result<AccountState, Error>?

        wallet.getAccountState {
            result = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), defaultAccountState(accountId: 44))
    }

    private func defaultDepositingState() -> AccountState.Depositing {
        let balance = AccountState.Balance(amount: "10", expectedBlockNumber: 12345)
        return AccountState.Depositing(balances: ["ETH" : balance])
    }
    
    private func defaultState() -> AccountState.State {
        return AccountState.State(nonce: UInt32.max,
                                  pubKeyHash: "17f3708f5e2b2c39c640def0cf0010fd9dd9219650e389114ea9da47f5874184", balances: ["ETH" : "10"])
    }
    
    private func defaultAccountState(accountId: UInt32) -> AccountState {
        return AccountState(address: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                            id: accountId,
                            depositing: defaultDepositingState(),
                            committed: defaultState(),
                            verified: defaultState())
    }

    private func defaultTransactionFee(amount: BigUInt) -> TransactionFee {
        return TransactionFee(feeToken: "0x0000000000000000000000000000000000000000",
                              fee: amount)
    }
}

enum MockProviderError: Error {
    case error
}

struct MockProvider: Provider {
    
    let accountState: AccountState
    let expectedSignature: EthSignature?
    
    init(accountState: AccountState, expectedSignature: EthSignature? = nil) {
        self.accountState = accountState
        self.expectedSignature = expectedSignature
    }
    
    func accountState(address: String, completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        self.accountState(address: address, queue: .main, completion: completion)
    }
    
    func accountState(address: String, queue: DispatchQueue, completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        queue.async {
            completion(.success(accountState))
        }
    }
    
    func transactionFee(request: TransactionFeeRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void) {
    }
    
    func transactionFee(request: TransactionFeeBatchRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void) {
    }
    
    func tokens(completion: @escaping (ZKSyncResult<Tokens>) -> Void) {
        let token = Token(id: 0,
                          address: "0x0000000000000000000000000000000000000000",
                          symbol: "ETH",
                          decimals: 0)
        let tokens = Tokens(tokens: [token.address : token])
        completion(.success(tokens))
    }
    
    func tokenPrice(token: Token, completion: @escaping (ZKSyncResult<Decimal>) -> Void) {
    }
    
    func contractAddress(completion: @escaping (ZKSyncResult<ContractAddress>) -> Void) {
    }
    
    func contractAddress(queue: DispatchQueue, completion: @escaping (ZKSyncResult<ContractAddress>) -> Void) {
    }
    
    func submitTx<TX>(_ tx: TX, ethereumSignature: EthSignature?, fastProcessing: Bool, completion: @escaping (ZKSyncResult<String>) -> Void) where TX : ZkSyncTransaction {
        if ethereumSignature?.signature == self.expectedSignature?.signature,
           ethereumSignature?.type == self.expectedSignature?.type {
            completion(.success("success:hash"))
        } else {
            completion(.failure(MockProviderError.error))
        }
    }
    
    func submitTx<TX>(_ tx: TX, fastProcessing: Bool, completion: @escaping (ZKSyncResult<String>) -> Void) where TX : ZkSyncTransaction {
        completion(.success("success:hash"))
    }
    
    func submitTxBatch(txs: [TransactionSignaturePair], ethereumSignature: EthSignature?, completion: @escaping (ZKSyncResult<[String]>) -> Void) {
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
}

extension AccountState: Equatable {
    public static func == (lhs: AccountState, rhs: AccountState) -> Bool {
        return lhs.address == rhs.address &&
            lhs.id == rhs.id &&
            lhs.depositing == rhs.depositing &&
            lhs.committed == rhs.committed &&
            lhs.verified == rhs.verified
    }
}

extension AccountState.Depositing: Equatable {
    public static func == (lhs: AccountState.Depositing, rhs: AccountState.Depositing) -> Bool {
        return lhs.balances == rhs.balances
    }
}

extension AccountState.Balance: Equatable {
    public static func == (lhs: AccountState.Balance, rhs: AccountState.Balance) -> Bool {
        return lhs.amount == rhs.amount &&
            lhs.expectedBlockNumber == rhs.expectedBlockNumber
    }
}

extension AccountState.State: Equatable {
    public static func == (lhs: AccountState.State, rhs: AccountState.State) -> Bool {
        return lhs.nonce == rhs.nonce &&
            lhs.pubKeyHash == rhs.pubKeyHash &&
            lhs.balances == rhs.balances
    }
}

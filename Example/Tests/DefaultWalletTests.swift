//
//  DefaultWalletTests.swift
//  ZKSyncSDK_Tests
//
//  Created by Eugene Belyakov on 20/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import BigInt
@testable import ZKSync

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
        let ethSignature = EthSignature(signature: "0x3c206b2d9b6dc055aba53ccbeca6c1620a42fc45bdd66282618fd1f055fdf90c00101973507694fb66edaa5d4591a2b4f56bbab876dc7579a17c7fe309c80301", type: .ethereumSignature)
        
        let provider = MockProvider(accountState: defaultAccountState(accountId: 55),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)
        
        let exp = expectation(description: "setSigningKey")
        wallet.setSigningKey(fee: defaultTransactionFee(amount: 1000000000), nonce: 13, oncahinAuth: true, timeRange: TimeRange(validFrom: 0, validUntil: 4294967295)) { (_) in
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        let receivedTX = provider.received as? ChangePubKey<ChangePubKeyOnchain>
        XCTAssertNotNil(receivedTX)
        XCTAssertEqual(receivedTX, ChangePubKey<ChangePubKeyOnchain>.defaultTX)
    }
    
    func testTransfer() throws {
        let ethSignature = EthSignature(signature: "0x4684a8f03c5da84676ff4eae89984f20057ce288b3a072605cbf93ef4bcc8a021306b13a88c6d3adc68347f4b68b1cbdf967861005e934afa50ce2e0c5bced791b", type: .ethereumSignature)
        
        let provider = MockProvider(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)
        
        let exp = expectation(description: "transfer")
        var result: Result<String, Error>?
        wallet.transfer(to: "0x19aa2ed8712072e918632259780e587698ef58df",
                        amount: 1000000000000,
                        fee: defaultTransactionFee(amount: 1000000),
                        nonce: 12,
                        timeRange: TimeRange(validFrom: 0, validUntil: 4294967295)) {
            result = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), "success:hash")
    }
    
    func testWithdraw() throws {
        let ethSignature = EthSignature(signature: "0xa87d458c96f2b78c8b615c7703540d5af0c0b5266b12dbd648d8f6824958ed907f40cae683fa77e7a8a5780381cae30a94acf67f880ed30483c5a8480816fc9d1c", type: .ethereumSignature)
        
        let provider = MockProvider(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)
        
        let exp = expectation(description: "withdraw")
        var result: Result<String, Error>?
        wallet.withdraw(ethAddress: "0x19aa2ed8712072e918632259780e587698ef58df",
                        amount: 1000000000000,
                        fee: defaultTransactionFee(amount: 1000000),
                        nonce: 12,
                        fastProcessing: false,
                        timeRange: TimeRange(validFrom: 0, validUntil: 4294967295)) {
            result = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), "success:hash")
    }
    
    func testForcedExit() throws {
        let ethSignature = EthSignature(signature: "0x4db4eaa3ca3c1b750bc95361847c7dcda5bcc08644f5a80590c604d728f5a01f52bc767a15e8d6fc8293c3ac46f8fbb3ae4aa4bd3db7db1b0ec8959e63b1861e1c", type: .ethereumSignature)
        
        let provider = MockProvider(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)

        let exp = expectation(description: "forcedExit")
        var result: Result<String, Error>?
        
        wallet.forcedExit(target: "0x19aa2ed8712072e918632259780e587698ef58df",
                          fee: defaultTransactionFee(amount: 1000000),
                          nonce: 12,
                          timeRange: TimeRange(validFrom: 0, validUntil: 4294967295)) {
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
        let balance = AccountState.Balance(amount: "10", expectedAcceptBlock: 12345)
        return AccountState.Depositing(balances: ["ETH" : balance])
    }
    
    private func defaultState() -> AccountState.State {
        return AccountState.State(nonce: UInt32.max,
                                  pubKeyHash: "17f3708f5e2b2c39c640def0cf0010fd9dd9219650e389114ea9da47f5874184", balances: ["ETH" : "10"],
                                  nfts: [:])
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

class MockProvider: Provider {
    
    let accountState: AccountState
    let expectedSignature: EthSignature?
    var received: ZkSyncTransaction?
    
    init(accountState: AccountState, expectedSignature: EthSignature? = nil) {
        self.accountState = accountState
        self.expectedSignature = expectedSignature
    }
    
    func accountState(address: String, completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        self.accountState(address: address, queue: .main, completion: completion)
    }
    
    func accountState(address: String, queue: DispatchQueue, completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        queue.async {
            completion(.success(self.accountState))
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
        received = tx
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
            lhs.expectedAcceptBlock == rhs.expectedAcceptBlock
    }
}

extension AccountState.State: Equatable {
    public static func == (lhs: AccountState.State, rhs: AccountState.State) -> Bool {
        return lhs.nonce == rhs.nonce &&
            lhs.pubKeyHash == rhs.pubKeyHash &&
            lhs.balances == rhs.balances
    }
}


extension ChangePubKey: Equatable where T == ChangePubKeyOnchain{
    public static func == (lhs: ChangePubKey<T>, rhs: ChangePubKey<T>) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.account == rhs.account &&
            lhs.newPkHash == rhs.newPkHash &&
            lhs.feeToken == rhs.feeToken &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }
    
    static var defaultTX: ChangePubKey<ChangePubKeyOnchain> {
        let tx = ChangePubKey<ChangePubKeyOnchain>(accountId: 55,
                                                   account: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                                                   newPkHash: "sync:18e8446d7748f2de52b28345bdbc76160e6b35eb",
                                                   feeToken: 0,
                                                   fee: "1000000000",
                                                   nonce: 13,
                                                   timeRange: TimeRange(validFrom: 0, validUntil: 4294967295))
        tx.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490", signature: "3c206b2d9b6dc055aba53ccbeca6c1620a42fc45bdd66282618fd1f055fdf90c00101973507694fb66edaa5d4591a2b4f56bbab876dc7579a17c7fe309c80301")
        tx.ethAuthData = ChangePubKeyOnchain()
        return tx
    }
}

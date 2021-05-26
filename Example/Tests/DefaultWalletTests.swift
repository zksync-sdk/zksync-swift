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
        let receivedTX = provider.received as? Transfer
        XCTAssertNotNil(receivedTX)
        XCTAssertEqual(receivedTX, Transfer.defaultTX)
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
        let receivedTX = provider.received as? Withdraw
        XCTAssertNotNil(receivedTX)
        XCTAssertEqual(receivedTX, Withdraw.defaultTX)
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
        let receivedTX = provider.received as? ForcedExit
        XCTAssertNotNil(receivedTX)
        XCTAssertEqual(receivedTX, ForcedExit.defaultTX)
    }
    
    func testMintNFT() throws {
        let ethSignature = EthSignature(signature: "0xac4f8b1ad65ea143dd2a940c72dd778ba3e07ee766355ed237a89a0b7e925fe76ead0a04e23db1cc1593399ee69faeb31b2e7e0c6fbec70d5061d6fbc431d64a1b", type: .ethereumSignature)
        
        let provider = MockProvider(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)

        let exp = expectation(description: "mintNFT")
        var result: Result<String, Error>?
        
        wallet.mintNFT(recepient: "0x19aa2ed8712072e918632259780e587698ef58df",
                       contentHash: "0x0000000000000000000000000000000000000000000000000000000000000123",
                       fee: defaultTransactionFee(amount: 1000000),
                       nonce: 12) {
            result = $0
            exp.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), "success:hash")
        let receivedTX = provider.received as? MintNFT
        XCTAssertNotNil(receivedTX)
        XCTAssertEqual(receivedTX, MintNFT.defaultTX)
    }
    
    func testWithdrawNFT() throws {
        let ethSignature = EthSignature(signature: "0x4a50341da6d2b1f0b64a4e37f753c02c43623e89cb0a291026c37fdcc723da9665453ce622f4dd6237bd98430ef0d75755694b1968f3b2d0ea8598f8bc43accf1b", type: .ethereumSignature)
        
        let provider = MockProvider(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)

        let exp = expectation(description: "withdrawNFT")
        var result: Result<String, Error>?

        let nft = NFT(id: 100000,
                      symbol: "NFT-100000",
                      creatorId: 3,
                      contentHash: "0x0000000000000000000000000000000000000000000000000000000000000123",
                      creatorAddress: "0x19aa2ed8712072e918632259780e587698ef58df",
                      serialId: 1,
                      address: "0x7059cafb9878ac3c95daa5bc33a5728c678d28b3")
        
        wallet.withdrawNFT(to: "0x19aa2ed8712072e918632259780e587698ef58df",
                           token: nft,
                           fee: defaultTransactionFee(amount: 1000000),
                           nonce: 12) {
            result = $0
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(try result?.get(), "success:hash")
        let receivedTX = provider.received as? WithdrawNFT
        XCTAssertNotNil(receivedTX)
        XCTAssertEqual(receivedTX, WithdrawNFT.defaultTX)
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


extension ChangePubKey: Equatable where T == ChangePubKeyOnchain {
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
        tx.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490", signature: "31a6be992eeb311623eb466a49d54cb1e5b3d44e7ccc27d55f82969fe04824aa92107fefa6b0a2d7a07581ace7f6366a5904176fae4aadec24d75d3d76028500")
        tx.ethAuthData = ChangePubKeyOnchain()
        return tx
    }
}

extension ForcedExit: Equatable {
    public static func == (lhs: ForcedExit, rhs: ForcedExit) -> Bool {
        return lhs.initiatorAccountId == rhs.initiatorAccountId &&
            lhs.target == rhs.target &&
            lhs.token == rhs.token &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }

    static var defaultTX: ForcedExit {
        let tx = ForcedExit(initiatorAccountId: 44,
                            target: "0x19aa2ed8712072e918632259780e587698ef58df",
                            token: 0,
                            fee: "1000000",
                            nonce: 12,
                            timeRange: .max)
        tx.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                 signature: "50a9b498ffb54a24ba77fca2d9a72f4d906464d14c73c8f3b4a457e9149ba0885c6de37706ced49ae8401fb59000d4bcf9f37bcdaeab20a87476c3e08088b702")
        return tx
    }
}

extension Transfer: Equatable {
    public static func == (lhs: Transfer, rhs: Transfer) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.from == rhs.from &&
            lhs.to == rhs.to &&
            lhs.token == rhs.token &&
            lhs.amount == rhs.amount &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }

    static var defaultTX: Transfer {
        let tx = Transfer(accountId: 44,
                          from: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                          to: "0x19aa2ed8712072e918632259780e587698ef58df",
                          token: 0,
                          amount: 1000000000000,
                          fee: "1000000",
                          nonce: 12,
                          timeRange: .max)
        tx.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                 signature: "5c3304c8d1a8917580c9a3f8edb9d8698cbe9e6e084af93c13ac3564fa052588b93830785b3d0f60a1a193ec4fff61f81b95f0d16bf128ee21a6ceb09ef88602")
        return tx
    }
}

extension Withdraw: Equatable {
    
    public static func == (lhs: Withdraw, rhs: Withdraw) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.from == rhs.from &&
            lhs.to == rhs.to &&
            lhs.token == rhs.token &&
            lhs.amount == rhs.amount &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }

    static var defaultTX: Withdraw {
        let tx = Withdraw(accountId: 44,
                          from: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                          to: "0x19aa2ed8712072e918632259780e587698ef58df",
                          token: 0,
                          amount: 1000000000000,
                          fee: "1000000",
                          nonce: 12,
                          timeRange: .max)
        tx.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                 signature: "3e2866bb00f892170cc3592d48aec7eb4afba75bdd0a530780fa1dcbdf857d07d75deb774142a93e3d1ca3be29e614e50892b95702b6461f86ddf78b9ab11a01")
        return tx
    }
}

extension MintNFT: Equatable {
    
    public static func == (lhs: MintNFT, rhs: MintNFT) -> Bool {
        return lhs.creatorId == rhs.creatorId &&
            lhs.creatorAddress == rhs.creatorAddress &&
            lhs.contentHash == rhs.contentHash &&
            lhs.recipient == rhs.recipient &&
            lhs.fee == rhs.fee &&
            lhs.feeToken == rhs.feeToken &&
            lhs.nonce == rhs.nonce &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }

    static var defaultTX: MintNFT {
        let tx = MintNFT(creatorId: 44,
                         creatorAddress: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                         contentHash: "0x0000000000000000000000000000000000000000000000000000000000000123",
                         recipient: "0x19aa2ed8712072e918632259780e587698ef58df",
                         fee: "1000000",
                         feeToken: 0,
                         nonce: 12)
        tx.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                 signature: "8c119b01ff8ae75ba5aabaa4ad480690e6a56d6e99d430ecac3bc3beacbaba28b3740cb20574d130281874fc70daaab884ee8e03a510e9ca9c1c677a2412cf03")
        return tx
    }
}

extension WithdrawNFT: Equatable {
    
    public static func == (lhs: WithdrawNFT, rhs: WithdrawNFT) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.from == rhs.from &&
            lhs.to == rhs.to &&
            lhs.token == rhs.token &&
            lhs.feeToken == rhs.feeToken &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }

    static var defaultTX: WithdrawNFT {
        let tx = WithdrawNFT(accountId: 44,
                             from: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                             to: "0x19aa2ed8712072e918632259780e587698ef58df",
                             token: 100000,
                             feeToken: 0,
                             fee: "1000000",
                             nonce: 12,
                             timeRange: .max)
        tx.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                 signature: "9d94324425f23d09bf76df52e520e8da4561718057eb29fe6d760945be986b8e3a1955d9c02cf415558f533b7d9573564798db9586cc5ba1fdc44f711e455e03")
        return tx
    }
}


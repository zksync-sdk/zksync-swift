//
//  DefaultWalletTests.swift
//  ZKSyncExample
//
//  Created by Eugene Belyakov on 20/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import BigInt
@testable import ZKSync

class DefaultWalletTests: XCTestCase {

    static let EthPrivateKey = "0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"

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
        // swiftlint:disable:next line_length
        let ethSignature = EthSignature(signature: "0x3c206b2d9b6dc055aba53ccbeca6c1620a42fc45bdd66282618fd1f055fdf90c00101973507694fb66edaa5d4591a2b4f56bbab876dc7579a17c7fe309c80301",
                                        type: .ethereumSignature)

        let provider = MockProvider(accountState: defaultAccountState(accountId: 55),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)

        let exp = expectation(description: "setSigningKey")
        wallet.setSigningKey(fee: defaultTransactionFee(amount: 1000000000),
                             nonce: 13,
                             oncahinAuth: true,
                             timeRange: TimeRange(validFrom: 0, validUntil: 4294967295)) { (_) in
            exp.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        let receivedTX = provider.received as? ChangePubKey<ChangePubKeyOnchain>
        XCTAssertNotNil(receivedTX)
        XCTAssertEqual(receivedTX, ChangePubKey<ChangePubKeyOnchain>.defaultTX)
    }

    func testTransfer() throws {
        // swiftlint:disable:next line_length
        let ethSignature = EthSignature(signature: "0x4684a8f03c5da84676ff4eae89984f20057ce288b3a072605cbf93ef4bcc8a021306b13a88c6d3adc68347f4b68b1cbdf967861005e934afa50ce2e0c5bced791b",
                                        type: .ethereumSignature)

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
        // swiftlint:disable:next line_length
        let ethSignature = EthSignature(signature: "0xa87d458c96f2b78c8b615c7703540d5af0c0b5266b12dbd648d8f6824958ed907f40cae683fa77e7a8a5780381cae30a94acf67f880ed30483c5a8480816fc9d1c",
                                        type: .ethereumSignature)

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
        // swiftlint:disable:next line_length
        let ethSignature = EthSignature(signature: "0x4db4eaa3ca3c1b750bc95361847c7dcda5bcc08644f5a80590c604d728f5a01f52bc767a15e8d6fc8293c3ac46f8fbb3ae4aa4bd3db7db1b0ec8959e63b1861e1c",
                                        type: .ethereumSignature)

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
        // swiftlint:disable:next line_length
        let ethSignature = EthSignature(signature: "0xac4f8b1ad65ea143dd2a940c72dd778ba3e07ee766355ed237a89a0b7e925fe76ead0a04e23db1cc1593399ee69faeb31b2e7e0c6fbec70d5061d6fbc431d64a1b",
                                        type: .ethereumSignature)

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
        // swiftlint:disable:next line_length
        let ethSignature = EthSignature(signature: "0x4a50341da6d2b1f0b64a4e37f753c02c43623e89cb0a291026c37fdcc723da9665453ce622f4dd6237bd98430ef0d75755694b1968f3b2d0ea8598f8bc43accf1b",
                                        type: .ethereumSignature)

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

    func testCreateOrder() throws {
        let provider = MockProvider(accountState: defaultAccountState(accountId: 6))
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)

        let tokenSell = Token(id: 0, address: Token.DefaultAddress, symbol: "ETH", decimals: 3)
        let tokenBuy = Token(id: 2, address: Token.DefaultAddress, symbol: "DAI", decimals: 3)

        let result = try wallet.buildSignedOrder(recepient: "0x823b6a996cea19e0c41e250b20e2e804ea72ccdf",
                                                 sell: tokenSell,
                                                 buy: tokenBuy,
                                                 ratio: (1, 2),
                                                 amount: 1000000,
                                                 nonce: 18,
                                                 timeRange: .max)

        XCTAssertEqual(result, Order.defaultOrder)
    }

    func testSyncSwap() throws {
        // swiftlint:disable:next line_length
        let ethSignature = EthSignature(signature: "0x3a459b40838e9445adc59e0cba4bf769b68deda8dadfedfe415f9e8be1c55443090f66cfbd13d96019b9faafb996a5a69d1bc0d1061f08ebf7cb8a1687e09a0f1c",
                                        type: .ethereumSignature)

        let token = Token(id: 3, address: Token.DefaultAddress, symbol: "USDT", decimals: 1)

        let provider = MockProvider(accountState: defaultAccountState(accountId: 5),
                                    expectedSignature: ethSignature,
                                    tokens: Tokens(tokens: [token.address: token]))
        let wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: provider)

        let exp = expectation(description: "swap")
        var result: Result<String, Error>?

        wallet.swap(order1: Order.defaultOrderA,
                    order2: Order.defaultOrderB,
                    amount1: 1000000,
                    amount2: 2500000,
                    fee: defaultTransactionFee(amount: 123),
                    nonce: 1) {
            result = $0
            exp.fulfill()
        }
        waitForExpectations(timeout: 120, handler: nil)

        XCTAssertEqual(try result?.get(), "success:hash")
        let receivedTX = provider.received as? Swap
        XCTAssertNotNil(receivedTX)
        XCTAssertEqual(receivedTX, Swap.defaultTX)
    }

    private func defaultDepositingState() -> AccountState.Depositing {
        let balance = AccountState.Balance(amount: "10", expectedAcceptBlock: 12345)
        return AccountState.Depositing(balances: ["ETH": balance])
    }

    private func defaultState() -> AccountState.State {
        return AccountState.State(nonce: UInt32.max,
                                  pubKeyHash: "17f3708f5e2b2c39c640def0cf0010fd9dd9219650e389114ea9da47f5874184",
                                  balances: ["ETH": "10"],
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

    func submitTx<TX>(_ tx: TX,
                      ethereumSignature: EthSignature?,
                      fastProcessing: Bool,
                      completion: @escaping (ZKSyncResult<String>) -> Void) where TX: ZkSyncTransaction {
        received = tx
        if ethereumSignature?.signature == self.expectedSignature?.signature,
           ethereumSignature?.type == self.expectedSignature?.type {
            completion(.success("success:hash"))
        } else {
            completion(.failure(MockProviderError.error))
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
        tx.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                 // swiftlint:disable:next line_length
                                 signature: "85782959384c1728192b0fe9466a4273b6d0e78e913eea894b780e0236fc4c9d673d3833e895bce992fc113a4d16bba47ef73fed9c4fca2af09ed06cd6885802")
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
                                 // swiftlint:disable:next line_length
                                 signature: "b1b82f7ac37e2d4bd675e4a5cd5e48d9fad1739282db8a979c3e4d9e39d794915667ee2c125ba24f4fe81ad6d19491eef0be849a823ea6567517b7e207214705")
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
                                 signature: "b3211c7e15d31d64619e0c7f65fce8c6e45637b5cfc8711478c5a151e6568d875ec7f48e040225fe3cc7f1e7294625cad6d98b4595d007d36ef62122de16ae01")
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
                                 // swiftlint:disable:next line_length
                                 signature: "11dc47fced9e6ffabe33112a4280c02d0c1ffa649ba3843eec256d427b90ed82e495c0cee2138d5a9e20328d31cb97b70d7e2ede0d8d967678803f4b5896f701")
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
                                 // swiftlint:disable:next line_length
                                 signature: "5cf4ef4680d58e23ede08cc2f8dd33123c339788721e307a813cdf82bc0bac1c10bc861c68d0b5328e4cb87b610e4dfdc13ddf8a444a4a2ac374ac3c73dbec05")
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
                                 signature: "1236180fe01b42c0c3c084d152b0582e714fa19da85900777e811f484a5b3ea434af320f66c7c657a33024d7be22cea44b7406d0af88c097a9d7d6b5d7154d02")
        return tx
    }
}

extension Swap: Equatable {

    public static func == (lhs: Swap, rhs: Swap) -> Bool {
        return lhs.submitterId == rhs.submitterId &&
            lhs.submitterAddress == rhs.submitterAddress &&
            lhs.nonce == rhs.nonce &&
            lhs.orders == rhs.orders &&
            lhs.amounts == rhs.amounts &&
            lhs.fee == rhs.fee &&
            lhs.feeToken == rhs.feeToken &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }
    static var defaultTX: Swap {
        return Swap(submitterId: 5,
                    submitterAddress: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                    nonce: 1,
                    orders: (Order.defaultOrderA, Order.defaultOrderB),
                    amounts: (1000000, 2500000),
                    fee: "123",
                    feeToken: 3,
                    signature: Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                         // swiftlint:disable:next line_length
                                         signature: "c13aabacf96448efb47763554753bfe2acc303a8297c8af59e718d685d422a901a43c42448f95cca632821df1ccb754950196e8444c0acef253c42c1578b5401"))
    }
}

extension Order: Equatable {

    public static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.recepientAddress == rhs.recepientAddress &&
            lhs.nonce == rhs.nonce &&
            lhs.tokenBuy == rhs.tokenBuy &&
            lhs.tokenSell == rhs.tokenSell &&
            lhs.ratio == rhs.ratio &&
            lhs.amount == rhs.amount &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.ethereumSignature == rhs.ethereumSignature
    }

    static var defaultOrder: Order {
        var order = Order(accountId: 6,
                          recepientAddress: "0x823b6a996cea19e0c41e250b20e2e804ea72ccdf",
                          nonce: 18,
                          tokenBuy: 2,
                          tokenSell: 0,
                          ratio: (1, 2),
                          amount: 1000000,
                          timeRange: .max)
        // swiftlint:disable:next line_length
        order.ethereumSignature = EthSignature(signature: "0x841a4ed62572883b2272a56164eb33f7b0649029ba588a7230928cff698b49383045b47d35dcdee1beb33dd4ca6b944b945314a206f3f2838ddbe389a34fc8cb1c",
                                               type: .ethereumSignature)

        order.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                    // swiftlint:disable:next line_length
                                    signature: "b76c83011ea9e14cf679d35b9a7084832a78bf3f975c5b5c3315f80993c227afb7a1cd7e7b8fc225a48d8c9be78335736115890df5bbacfc52ecf47b4e089500")
        return order
    }

    static var defaultOrderA: Order {
        return Order(accountId: 6,
                     recepientAddress: "0x823b6a996cea19e0c41e250b20e2e804ea72ccdf",
                     nonce: 18,
                     tokenBuy: 2,
                     tokenSell: 1,
                     ratio: (1, 2),
                     amount: 1000000,
                     timeRange: .max)
    }

    static var defaultOrderB: Order {
        return Order(accountId: 44,
                     recepientAddress: "0x63adbb48d1bc2cf54562910ce54b7ca06b87f319",
                     nonce: 101,
                     tokenBuy: 1,
                     tokenSell: 2,
                     ratio: (3, 1),
                     amount: 2500000,
                     timeRange: .max)
    }
}

extension EthSignature: Equatable {
    public static func == (lhs: EthSignature, rhs: EthSignature) -> Bool {
        return lhs.signature == rhs.signature &&
            lhs.type == lhs.type
    }
}

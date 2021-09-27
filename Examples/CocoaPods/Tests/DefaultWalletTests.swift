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

// swiftlint:disable:next type_body_length
class DefaultWalletTests: XCTestCase {

    static let EthPrivateKey = "0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"

    var zkSigner: ZkSigner!
    var ethSigner: DefaultEthSigner!
    var wallet: DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>!

    override func setUpWithError() throws {
        var message = "Access zkSync account.\n\nOnly sign this message for a trusted client!"
        let chainId: ChainId = .mainnet

        if chainId != .mainnet {
            message = "\(message)\nChain ID: \(chainId.id)."
        }

        ethSigner = try DefaultEthSigner(privateKey: DefaultWalletTests.EthPrivateKey)
        let signature = try ethSigner.sign(message: message.data(using: .utf8)!)
        zkSigner = try ZkSigner(signature: signature)
        let provider = ProviderMock(accountState: defaultAccountState(accountId: 44))
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

        let provider = ProviderMock(accountState: defaultAccountState(accountId: 55),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

        let exp = expectation(description: "setSigningKey")
        wallet.setSigningKey(fee: defaultTransactionFee(amount: 1000000000),
                             nonce: 13,
                             onchainAuth: true,
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

        let provider = ProviderMock(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

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

        let provider = ProviderMock(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

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

        let provider = ProviderMock(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

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

        let provider = ProviderMock(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

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

        let provider = ProviderMock(accountState: defaultAccountState(accountId: 44),
                                    expectedSignature: ethSignature)
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

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
        let provider = ProviderMock(accountState: defaultAccountState(accountId: 44))
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

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
        let provider = ProviderMock(accountState: defaultAccountState(accountId: 6))
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

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

        let provider = ProviderMock(accountState: defaultAccountState(accountId: 5),
                                    expectedSignature: ethSignature,
                                    tokens: Tokens(tokens: [token.address: token]))
        let wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                            zkSigner: zkSigner,
                                                                            provider: provider)

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

    func testCreate2Auth() {
        let token = defaultToken()
        let tokens = [
            token.address: token
        ]
        let provider = ProviderMock(accountState: defaultAccountState(accountId: 55),
                                    tokens: Tokens(tokens: tokens))

        let changePubKeyCREATE2Expectation = expectation(description: "ChangePubKeyCREATE2 expectation")

        provider.submitTx(ChangePubKey<ChangePubKeyCREATE2>.defaultTX,
                          ethereumSignature: nil,
                          fastProcessing: false) { (result) in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, "success:hash")
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            changePubKeyCREATE2Expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        let setSigningKeyExpectation = expectation(description: "setSigningKey expectation")

        do {
            let creatorAddress = "0x" + [UInt8](repeating: 0, count: 40).toHexString()
            let salt = "0x" + [UInt8](repeating: 0, count: 32).toHexString()
            let codeHash = "0x" + [UInt8](repeating: 0, count: 32).toHexString()
            let create2Data = ChangePubKeyCREATE2(creatorAddress: creatorAddress,
                                                  saltArg: salt,
                                                  codeHash: codeHash)
            let ethSigner = try Create2EthSigner(zkSigner: zkSigner, create2Data: create2Data)
            let wallet = try DefaultWallet<ChangePubKeyCREATE2, Create2EthSigner>(ethSigner: ethSigner,
                                                                                  zkSigner: zkSigner,
                                                                                  provider: provider)
            wallet.setSigningKey(fee: defaultTransactionFee(amount: 1000000000),
                                 nonce: 13,
                                 onchainAuth: false,
                                 timeRange: TimeRange(validFrom: 0, validUntil: 4294967295)) { result in
                switch result {
                case .success(let message):
                    XCTAssertEqual(message, "success:hash")
                case .failure(let error):
                    XCTFail("Failed with error: \(error)")
                }
                setSigningKeyExpectation.fulfill()
            }
        } catch {
            XCTFail("Failed with error: \(error.localizedDescription)")
        }

        wait(for: [setSigningKeyExpectation], timeout: 5.0)
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

    private func defaultToken() -> Token {
        return Token(id: 0,
                     address: "0x0000000000000000000000000000000000000000",
                     symbol: "ETH",
                     decimals: 0)
    }
}

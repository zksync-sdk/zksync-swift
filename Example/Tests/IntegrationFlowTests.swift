//
//  IntegrationFlowTests.swift
//  ZKSyncSDK_Tests
//
//  Created by Eugene Belyakov on 21/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import ZKSyncSwift
import web3swift
import PromiseKit
import BigInt

class IntegrationFlowTests: XCTestCase {
    static let PrivateKey = "0xc5720cedfd30efcad48ecd5f393dde90f7a6b966f883da383154a5ed21c58747";
    
    var wallet: Wallet!
    var ethereum: EthereumProvider!
    
    var ethSigner: EthSigner!
    var zkSigner: ZkSigner!
    
    let queue = DispatchQueue.global(qos: .default)
    
    override func setUpWithError() throws {
        ethSigner = try DefaultEthSigner(privateKey: IntegrationFlowTests.PrivateKey)
        zkSigner = try ZkSigner(ethSigner: ethSigner, chainId: .ropsten)
        
        wallet = try DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, provider: DefaultProvider(chainId: .ropsten))
        ethereum = try wallet.createEthereumProvider(web3: Web3.InfuraRopstenWeb3())
    }
    
    override func tearDownWithError() throws {
        wallet = nil
        ethereum = nil
        ethSigner = nil
        zkSigner = nil
    }
    
    func test_01_CreateAccount() throws {
        let amount = Web3.Utils.parseToBigUInt("1", units: .eth)!
        XCTAssertNoThrow(try ethereum.deposit(token: .ETH,
                                              amount: amount,
                                              userAddress: ethSigner.address).wait())
    }
    
    func test_02_SetupPublicKey() throws {
        let exp = expectation(description: "setPublicKey")
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.getTransactionFeePromise(for: .changePubKey, tokenIdentifier: Token.ETH.address).map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.setSigningKeyPromise(fee: fee,
                                                    nonce: state.committed.nonce,
                                                    oncahinAuth: false)
        }.done(on: queue) { (hash) in
            exp.fulfill()
        }.catch(on: queue) { (error) in
            XCTFail("\(error)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_03_SetupPublicKeyOnChain() throws {
        let exp = expectation(description: "setPublicKeyOnChain")
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state -> Promise<TransactionSendingResult> in
            let hash = self.zkSigner.publicKeyHash
            let pureHash = String(hash.suffix(from: hash.index(hash.startIndex, offsetBy: 5)))
            return self.ethereum.setAuthPubkeyHash(pubKeyhash: pureHash, nonce: state.committed.nonce)
        }.done(on: queue) { (hash) in
            exp.fulfill()
        }.catch(on: queue) { (error) in
            XCTFail("\(error)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
        
    func test_04_IsPublicKeyIsSetOnChain() throws {
        let exp = expectation(description: "isPublicKeySetOnChain")
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.ethereum.isOnChainAuthPubkeyHashSet(nonce: state.committed.nonce)
        }.done { (value) in
            XCTAssertTrue(value)
            exp.fulfill()
        }.catch(on: queue) { (error) in
            XCTFail("\(error)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_05_TransferFunds() throws {
        let exp = expectation(description: "transfer")
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.getTransactionFeePromise(for: .transfer,
                                                 address: self.ethSigner.address,
                                                 tokenIdentifier: Token.ETH.address).map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.transferPromise(to: self.ethSigner.address,
                                               amount: Web3.Utils.parseToBigUInt("1000000", units: .Gwei)!,
                                               fee: fee,
                                               nonce: nil)
        }.done(on: queue) { (hash) in
            exp.fulfill()
        }.catch(on: queue) { (error) in
            XCTFail("\(error)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_06_Withdraw() throws {
        let exp = expectation(description: "withdraw")
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.getTransactionFeePromise(for: .withdraw,
                                                 tokenIdentifier: Token.ETH.address).map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.withdrawPromise(ethAddress: state.address,
                                               amount: Web3.Utils.parseToBigUInt("1000", units: .Gwei)!,
                                               fee: fee,
                                               nonce: state.committed.nonce,
                                               fastProcessing: false)
        }.done(on: queue) { (hash) in
            exp.fulfill()
        }.catch(on: queue) { (error) in
            XCTFail("\(error)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func test_07_ForcedExit() throws {
        let exp = expectation(description: "forcedExit")
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.getTransactionFeePromise(for: .forcedExit,
                                                 address: self.ethSigner.address,
                                                 tokenIdentifier: Token.ETH.address).map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.forcedExitPromise(target: state.address,
                                                 fee: fee,
                                                 nonce: state.committed.nonce)
        }.done(on: queue) { (hash) in
            exp.fulfill()
        }.catch(on: queue) { (error) in
            XCTFail("\(error)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func test_08_FullExit() throws {
        let exp = expectation(description: "fullExit")
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.ethereum.fullExit(token: .ETH, accountId: state.id!)
        }.done(on: queue) { (value) in
            exp.fulfill()
        }.catch(on: queue) { (error) in
            XCTFail("\(error)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
        
    func test_09_GetTransactionFeeBatch() throws {
        
        let transactions = [
            TransactionTypeAddressPair(transactionType: .forcedExit, address: ethSigner.address),
            TransactionTypeAddressPair(transactionType: .transfer, address: "0xC8568F373484Cd51FDc1FE3675E46D8C0dc7D246"),
            TransactionTypeAddressPair(transactionType: .transfer, address: "0x98122427eE193fAcbb9Fbdbf6BDE7d9042A95a0f"),
            TransactionTypeAddressPair(transactionType: .changePubKey, address: ethSigner.address)
        ]
        let batch = TransactionFeeBatchRequest(transactionsAndAddresses: transactions,
        tokenIdentifier: Token.ETH.address)

        let exp = expectation(description: "transactionFeeBatch")
        
        firstly {
            self.wallet.getTransactionFeePromise(for: batch)
        }.done(on: queue) { details in
            exp.fulfill()
        }.catch(on: queue) { (error) in
            XCTFail("\(error)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func test_10_GetTokenPrice() {
        let exp = expectation(description: "getTokenPrice")
        self.wallet.provider.tokenPrice(token: .ETH) { (result) in
            if case let Swift.Result<Decimal, Error>.failure(error) = result {
                XCTFail("\(error)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_11_GetConfirmationsForEthOpAmount() {
        let exp = expectation(description: "getConfirmationsForEthOpAmount")
        self.wallet.provider.confirmationsForEthOpAmount { (result) in
            if case let Swift.Result<UInt64, Error>.failure(error) = result {
                XCTFail("\(error)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
}

//
//  IntegrationFlowTests.swift
//  ZKSyncSDK_Tests
//
//  Created by Eugene Belyakov on 21/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import ZKSync
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
        
        var finalResult: PromiseKit.Result<String>? = nil
        
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .changePubKey, address: self.wallet.address, tokenIdentifier: Token.ETH.address).map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.setSigningKeyPromise(fee: fee,
                                                    nonce: state.committed.nonce,
                                                    oncahinAuth: false,
                                                    timeRange: TimeRange(validFrom: 0, validUntil: 4294967295))
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_03_SetupPublicKeyOnChain() throws {
        let exp = expectation(description: "setPublicKeyOnChain")
        
        var finalResult: PromiseKit.Result<TransactionSendingResult>? = nil
        
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state -> Promise<TransactionSendingResult> in
            let hash = self.zkSigner.publicKeyHash
            let pureHash = String(hash.suffix(from: hash.index(hash.startIndex, offsetBy: 5)))
            return self.ethereum.setAuthPubkeyHash(pubKeyhash: pureHash, nonce: state.committed.nonce)
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_04_IsPublicKeyIsSetOnChain() throws {
        let exp = expectation(description: "isPublicKeySetOnChain")
        
        var finalResult: PromiseKit.Result<Bool>? = nil
        
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.ethereum.isOnChainAuthPubkeyHashSet(nonce: state.committed.nonce)
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_05_TransferFunds() throws {
        let exp = expectation(description: "transfer")
        
        var finalResult: PromiseKit.Result<String>? = nil
        
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .transfer,
                                                       address: self.ethSigner.address,
                                                       tokenIdentifier: Token.ETH.address).map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.transferPromise(to: self.ethSigner.address,
                                               amount: Web3.Utils.parseToBigUInt("1000000", units: .Gwei)!,
                                               fee: fee,
                                               nonce: nil)
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_06_BatchTransferFunds() throws {
        let exp = expectation(description: "transfer")
        
        var finalResult: PromiseKit.Result<[String]>? = nil
        
        firstly {
            self.wallet.getAccountStatePromise()
        }.map { state -> AccountState in
            guard state.id != nil else {
                throw WalletError.accountIdIsNull
            }
            return state
        }.then(on: queue) { state -> Promise<(TransactionFeeDetails, AccountState)> in
            let transactions = [
                TransactionTypeAddressPair(transactionType: .transfer, address: self.ethSigner.address),
                TransactionTypeAddressPair(transactionType: .withdraw, address: self.ethSigner.address)
            ]
            let request = TransactionFeeBatchRequest(transactionsAndAddresses: transactions,
                                                     tokenIdentifier: Token.ETH.address)
            
            return self.wallet.provider.transactionFeePromise(request: request)
                .map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<(SignedTransaction<Transfer>, TransactionFee, AccountState)> in
            
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.buildSignedTransferTx(to: self.ethSigner.address,
                                                     tokenIdentifier: fee.feeToken,
                                                     amount: Web3.Utils.parseToBigUInt("1000000", units: .Gwei)!,
                                                     fee: fee.fee,
                                                     accountId: state.id!,
                                                     nonce: state.committed.nonce)
                .map(on: self.queue) { ($0, fee, state) }
        }.then(on: queue) { (tx, fee, state) -> Promise<(SignedTransaction<Withdraw>, SignedTransaction<Transfer>, TransactionFee, AccountState)> in
            self.wallet.buildSignedWithdrawTx(to: self.ethSigner.address,
                                              tokenIdentifier: fee.feeToken,
                                              amount: Web3.Utils.parseToBigUInt("2000000", units: .Gwei)!,
                                              fee: 0,
                                              accountId: state.id!,
                                              nonce: state.committed.nonce)
                .map(on: self.queue) { ($0, tx, fee, state) }
        }.then(on: queue) { (tx1, tx2, fee, state) -> Promise<[String]> in
            let t1 = TransactionSignaturePair(tx: tx1.transaction, signature: tx1.ethereumSignature)
            let t2 = TransactionSignaturePair(tx: tx2.transaction, signature: tx2.ethereumSignature)
            
            return self.wallet.provider.submitTxBatchPromise(txs: [t1, t2])
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_07_Withdraw() throws {
        let exp = expectation(description: "withdraw")
        
        var finalResult: PromiseKit.Result<String>? = nil
        
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .withdraw, address: self.wallet.address,
                                                       tokenIdentifier: Token.ETH.address).map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.withdrawPromise(ethAddress: state.address,
                                               amount: Web3.Utils.parseToBigUInt("1000", units: .Gwei)!,
                                               fee: fee,
                                               nonce: state.committed.nonce,
                                               fastProcessing: false)
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_08_ForcedExit() throws {
        let exp = expectation(description: "forcedExit")
        
        var finalResult: PromiseKit.Result<String>? = nil
        
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .forcedExit,
                                                       address: self.ethSigner.address,
                                                       tokenIdentifier: Token.ETH.address).map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.forcedExitPromise(target: state.address,
                                                 fee: fee,
                                                 nonce: state.committed.nonce,
                                                 timeRange: TimeRange(validFrom: 0, validUntil: 4294967295))
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_09_FullExit() throws {
        let exp = expectation(description: "fullExit")
        
        var finalResult: PromiseKit.Result<TransactionSendingResult>? = nil
        
        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.ethereum.fullExit(token: .ETH, accountId: state.id!)
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_10_GetTransactionFeeBatch() throws {
        
        let transactions = [
            TransactionTypeAddressPair(transactionType: .forcedExit, address: ethSigner.address),
            TransactionTypeAddressPair(transactionType: .transfer, address: "0xC8568F373484Cd51FDc1FE3675E46D8C0dc7D246"),
            TransactionTypeAddressPair(transactionType: .transfer, address: "0x98122427eE193fAcbb9Fbdbf6BDE7d9042A95a0f"),
            TransactionTypeAddressPair(transactionType: .changePubKey, address: ethSigner.address)
        ]
        let batch = TransactionFeeBatchRequest(transactionsAndAddresses: transactions,
                                               tokenIdentifier: Token.ETH.address)
        
        let exp = expectation(description: "transactionFeeBatch")
        
        var finalResult: PromiseKit.Result<TransactionFeeDetails>? = nil
        
        firstly {
            self.wallet.provider.transactionFeePromise(request: batch)
        }.pipe { (result) in
            finalResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_11_GetTokenPrice() {
        let exp = expectation(description: "getTokenPrice")
        
        var finalResult: Swift.Result<Decimal, Error>? = nil
        self.wallet.provider.tokenPrice(token: .ETH) { (result) in
            finalResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .failure(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
    
    func test_12_GetConfirmationsForEthOpAmount() {
        let exp = expectation(description: "getConfirmationsForEthOpAmount")
        var finalResult: Swift.Result<UInt64, Error>? = nil
        self.wallet.provider.confirmationsForEthOpAmount { (result) in
            finalResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
        
        switch finalResult {
        case .failure(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }
}

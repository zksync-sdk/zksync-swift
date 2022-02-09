//
//  IntegrationFlowTests.swift
//  ZKSyncExample
//
//  Created by Eugene Belyakov on 21/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import ZKSync
import web3swift
import PromiseKit

enum InternalError: LocalizedError {
    case invalidToken
}

// swiftlint:disable:next type_body_length
class IntegrationFlowTests: XCTestCase {
    static let PrivateKey = "0x543b4b129b397dd460fe417276a0f6b83ae65f0d6d747ec1ea310e7adca2dc49"
    //static let PrivateKey = "0xc5720cedfd30efcad48ecd5f393dde90f7a6b966f883da383154a5ed21c58747";
    var wallet: DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>!
    var ethereum: EthereumProvider!

    var ethSigner: DefaultEthSigner!
    var zkSigner: ZkSigner!
    var pollingTransactionReceiptProcessor: PollingTransactionReceiptProcessor!

    let queue = DispatchQueue.global(qos: .default)

    override func setUpWithError() throws {
        ethSigner = try DefaultEthSigner(privateKey: IntegrationFlowTests.PrivateKey)

        var message = "Access zkSync account.\n\nOnly sign this message for a trusted client!"
        let chainId: ChainId = .mainnet

        if chainId != .mainnet {
            message = "\(message)\nChain ID: \(chainId.id)."
        }

        let signature = try ethSigner.sign(message: message.data(using: .utf8)!)
        zkSigner = try ZkSigner(signature: signature)

        let provider = DefaultProvider(chainId: .rinkeby)
        wallet = try DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                        zkSigner: zkSigner,
                                                                        provider: provider)
        ethereum = try wallet.createEthereumProvider(web3: Web3.InfuraRopstenWeb3())

        let pollInterval = DispatchTimeInterval.milliseconds(100)
        pollingTransactionReceiptProcessor = PollingTransactionReceiptProcessor(provider,
                                                                                pollInterval: pollInterval,
                                                                                attempts: 50)
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

        var finalResult: PromiseKit.Result<String>?

        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .changePubKeyECDSA,
                                                       address: self.wallet.address,
                                                       tokenIdentifier: Token.ETH.address)
                .map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.setSigningKeyPromise(fee: fee,
                                                    nonce: state.committed.nonce,
                                                    onchainAuth: false)
        }.pipe {
            finalResult = $0
            exp.fulfill()
        }

        waitForExpectations(timeout: 60, handler: nil)

        switch finalResult {
        case .fulfilled(let result):
            NSLog("Result: \(result)")
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }

    func test_03_SetupPublicKeyOnChain() throws {
        let exp = expectation(description: "setPublicKeyOnChain")

        var finalResult: PromiseKit.Result<TransactionSendingResult>?

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

        var finalResult: PromiseKit.Result<Bool>?

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

    // swiftlint:disable:next function_body_length
    func test_05_TransferFunds() throws {
        let exp = expectation(description: "transfer")

        var finalResult: PromiseKit.Result<String>?

        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .transfer,
                                                       address: self.ethSigner.address,
                                                       tokenIdentifier: Token.ETH.address)
                .map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, _) -> Promise<String> in
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

        guard let txHash = try? finalResult?.result.get() else {
            XCTFail("Hash should be valid.")
            return
        }

        var transactionDetailsResult: PromiseKit.Result<ZKSync.TransactionDetails>?

        let transactionReceiptExpectation = expectation(description: "Transaction expectation")
        firstly {
            self.pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
        }.pipe {
            transactionDetailsResult = $0
            transactionReceiptExpectation.fulfill()
        }

        wait(for: [transactionReceiptExpectation], timeout: 60.0)

        switch transactionDetailsResult {
        case .fulfilled(let transactionDetails):
            XCTAssertTrue(transactionDetails.executed)
            if let success = transactionDetails.success {
                XCTAssertTrue(success)
            } else {
                XCTFail("Success should be valid.")
            }
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            XCTFail("Unknown result.")
        }
    }

    // swiftlint:disable:next function_body_length
    func test_06_BatchTransferFunds() throws {
        let exp = expectation(description: "transfer")

        var finalResult: PromiseKit.Result<[String]>?

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
            // swiftlint:disable:next line_length
        }.then(on: queue) { (feeDetails, state) -> Promise<(SignedTransaction<Transfer>, TransactionFee, AccountState)> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.buildSignedTransferTx(to: self.ethSigner.address,
                                                     tokenIdentifier: fee.feeToken,
                                                     amount: Web3.Utils.parseToBigUInt("1000000", units: .Gwei)!,
                                                     fee: fee.fee,
                                                     accountId: state.id!,
                                                     nonce: state.committed.nonce,
                                                     timeRange: TimeRange(validFrom: 0, validUntil: 4294967295))
                .map(on: self.queue) { ($0, fee, state) }
            // swiftlint:disable:next line_length
        }.then(on: queue) { (signedTransaction, fee, state) -> Promise<(SignedTransaction<Withdraw>, SignedTransaction<Transfer>, TransactionFee, AccountState)> in
            self.wallet.buildSignedWithdrawTx(to: self.ethSigner.address,
                                              tokenIdentifier: fee.feeToken,
                                              amount: Web3.Utils.parseToBigUInt("2000000", units: .Gwei)!,
                                              fee: 0,
                                              accountId: state.id!,
                                              nonce: state.committed.nonce,
                                              timeRange: TimeRange(validFrom: 0, validUntil: 4294967295))
                .map(on: self.queue) { ($0, signedTransaction, fee, state) }
        }.then(on: queue) { (tx1, tx2, _, _) -> Promise<[String]> in
            let firstTransactionSignaturePair = TransactionSignaturePair(tx: tx1.transaction,
                                                                         signature: tx1.ethereumSignature)

            let secondTransactionSignaturePair = TransactionSignaturePair(tx: tx2.transaction,
                                                                          signature: tx2.ethereumSignature)

            let transactionSignaturePairs = [
                firstTransactionSignaturePair,
                secondTransactionSignaturePair
            ]
            return self.wallet.provider.submitTxBatchPromise(txs: transactionSignaturePairs)
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

        guard let txHashes = try? finalResult?.result.get().compactMap({ $0 }) else {
            XCTFail("Hashes should be valid.")
            return
        }

        for txHash in txHashes {
            var transactionDetailsResult: PromiseKit.Result<ZKSync.TransactionDetails>?

            let transactionReceiptExpectation = expectation(description: "Transaction expectation")
            firstly {
                self.pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
            }.pipe {
                transactionDetailsResult = $0
                transactionReceiptExpectation.fulfill()
            }

            wait(for: [transactionReceiptExpectation], timeout: 60.0)

            switch transactionDetailsResult {
            case .fulfilled(let transactionDetails):
                XCTAssertTrue(transactionDetails.executed)
                if let success = transactionDetails.success {
                    NSLog("Transaction details: \(transactionDetails).")
                    XCTAssertTrue(success)
                } else {
                    XCTFail("Success should be valid.")
                }
            case .rejected(let error):
                XCTFail("\(error)")
            default:
                XCTFail("Unknown result.")
            }
        }
    }

    // swiftlint:disable:next function_body_length
    func test_07_Withdraw() throws {
        let exp = expectation(description: "withdraw")

        var finalResult: PromiseKit.Result<String>?

        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .withdraw,
                                                       address: self.wallet.address,
                                                       tokenIdentifier: Token.ETH.address)
                .map(on: self.queue) { ($0, state) }
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

        guard let txHash = try? finalResult?.result.get() else {
            XCTFail("Hash should be valid.")
            return
        }

        var transactionDetailsResult: PromiseKit.Result<ZKSync.TransactionDetails>?

        let transactionReceiptExpectation = expectation(description: "Transaction expectation")
        firstly {
            self.pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
        }.pipe {
            transactionDetailsResult = $0
            transactionReceiptExpectation.fulfill()
        }

        wait(for: [transactionReceiptExpectation], timeout: 60.0)

        switch transactionDetailsResult {
        case .fulfilled(let transactionDetails):
            XCTAssertTrue(transactionDetails.executed)
            if let success = transactionDetails.success {
                XCTAssertTrue(success)
            } else {
                XCTFail("Success should be valid.")
            }
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            XCTFail("Unknown result.")
        }
    }

    // swiftlint:disable:next function_body_length
    func test_08_ForcedExit() throws {
        let exp = expectation(description: "forcedExit")

        var finalResult: PromiseKit.Result<String>?

        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .forcedExit,
                                                       address: self.ethSigner.address,
                                                       tokenIdentifier: Token.ETH.address)
                .map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.forcedExitPromise(target: state.address,
                                                 fee: fee,
                                                 nonce: state.committed.nonce)
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

        guard let txHash = try? finalResult?.result.get() else {
            XCTFail("Hash should be valid.")
            return
        }

        var transactionDetailsResult: PromiseKit.Result<ZKSync.TransactionDetails>?

        let transactionReceiptExpectation = expectation(description: "Transaction expectation")
        firstly {
            self.pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
        }.pipe {
            transactionDetailsResult = $0
            transactionReceiptExpectation.fulfill()
        }

        wait(for: [transactionReceiptExpectation], timeout: 60.0)

        switch transactionDetailsResult {
        case .fulfilled(let transactionDetails):
            XCTAssertTrue(transactionDetails.executed)
            if let success = transactionDetails.success {
                NSLog("Transaction details: \(transactionDetails).")
                XCTAssertTrue(success)
            } else {
                XCTFail("Success should be valid.")
            }
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            XCTFail("Unknown result.")
        }
    }

    // swiftlint:disable:next function_body_length
    func test_09_MintNFT() throws {
        let exp = expectation(description: "mintNFT")

        var finalResult: PromiseKit.Result<String>?

        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .mintNFT,
                                                       address: state.address,
                                                       tokenIdentifier: Token.ETH.address)
                .map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)

            var bytes = [UInt8](repeating: 0, count: 32)
            _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            return self.wallet.mintNFT(recepient: state.address,
                                       contentHash: "0x" + bytes.toHexString(),
                                       fee: fee,
                                       nonce: state.committed.nonce)
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

        guard let txHash = try? finalResult?.result.get() else {
            XCTFail("Hash should be valid.")
            return
        }

        var transactionDetailsResult: PromiseKit.Result<ZKSync.TransactionDetails>?

        let transactionReceiptExpectation = expectation(description: "Transaction expectation")
        firstly {
            self.pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
        }.pipe {
            transactionDetailsResult = $0
            transactionReceiptExpectation.fulfill()
        }

        wait(for: [transactionReceiptExpectation], timeout: 60.0)

        switch transactionDetailsResult {
        case .fulfilled(let transactionDetails):
            XCTAssertTrue(transactionDetails.executed)
            if let success = transactionDetails.success {
                XCTAssertTrue(success)
            } else {
                XCTFail("Success should be valid.")
            }
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            XCTFail("Unknown result.")
        }
    }

    // swiftlint:disable:next function_body_length
    func test_10_WithdrawNFT() throws {
        let exp = expectation(description: "withdrawNFT")

        var finalResult: PromiseKit.Result<String>?

        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { state in
            self.wallet.provider.transactionFeePromise(for: .withdrawNFT,
                                                       address: state.address,
                                                       tokenIdentifier: Token.ETH.address)
                .map(on: self.queue) { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)

            guard let token = state.committed.nfts?.first?.value else {
                XCTFail("Token not available")
                return .init(error: InternalError.invalidToken)
            }

            return self.wallet.withdrawNFT(to: state.address,
                                           token: token,
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

        guard let txHash = try? finalResult?.result.get() else {
            XCTFail("Hash should be valid.")
            return
        }

        var transactionDetailsResult: PromiseKit.Result<ZKSync.TransactionDetails>?

        let transactionReceiptExpectation = expectation(description: "Transaction expectation")
        firstly {
            self.pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
        }.pipe {
            transactionDetailsResult = $0
            transactionReceiptExpectation.fulfill()
        }

        wait(for: [transactionReceiptExpectation], timeout: 60.0)

        switch transactionDetailsResult {
        case .fulfilled(let transactionDetails):
            XCTAssertTrue(transactionDetails.executed)
            if let success = transactionDetails.success {
                XCTAssertTrue(success)
            } else {
                XCTFail("Success should be valid.")
            }
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            XCTFail("Unknown result.")
        }
    }

    // swiftlint:disable:next function_body_length
    func test_11_TransferNFT() throws {
        let exp = expectation(description: "withdrawNFT")

        var finalResult: PromiseKit.Result<[String]>?

        firstly {
            self.wallet.getAccountStatePromise()
        }.then(on: queue) { (state) -> Promise<(TransactionFeeDetails, AccountState)> in
            let pairs = [
                TransactionTypeAddressPair(transactionType: .transfer, address: state.address),
                TransactionTypeAddressPair(transactionType: .transfer, address: state.address)
            ]
            let batchRequest = TransactionFeeBatchRequest(transactionsAndAddresses: pairs,
                                                          tokenIdentifier: Token.ETH.address)
            return self.wallet.provider.transactionFeePromise(request: batchRequest).map { ($0, state) }
        }.then(on: queue) { (feeDetails, state) -> Promise<[String]> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)

            guard let token = state.committed.nfts?.first?.value else {
                XCTFail("Token not available")
                return .init(error: InternalError.invalidToken)
            }

            return self.wallet.transferNFT(to: state.address,
                                           token: token,
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

        guard let txHashes = try? finalResult?.result.get().compactMap({ $0 }) else {
            XCTFail("Hashes should be valid.")
            return
        }

        for txHash in txHashes {
            var transactionDetailsResult: PromiseKit.Result<ZKSync.TransactionDetails>?

            let transactionReceiptExpectation = expectation(description: "Transaction expectation")
            firstly {
                self.pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
            }.pipe {
                transactionDetailsResult = $0
                transactionReceiptExpectation.fulfill()
            }

            wait(for: [transactionReceiptExpectation], timeout: 60.0)

            switch transactionDetailsResult {
            case .fulfilled(let transactionDetails):
                XCTAssertTrue(transactionDetails.executed)
                if let success = transactionDetails.success {
                    XCTAssertTrue(success)
                } else {
                    XCTFail("Success should be valid.")
                }
            case .rejected(let error):
                XCTFail("\(error)")
            default:
                XCTFail("Unknown result.")
            }
        }
    }

    func test_12_FullExit() throws {
        let exp = expectation(description: "fullExit")

        var finalResult: PromiseKit.Result<TransactionSendingResult>?

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

    func test_13_GetTransactionFeeBatch() throws {
        let transactions = [
            TransactionTypeAddressPair(transactionType: .forcedExit,
                                       address: ethSigner.address),
            TransactionTypeAddressPair(transactionType: .transfer,
                                       address: "0xC8568F373484Cd51FDc1FE3675E46D8C0dc7D246"),
            TransactionTypeAddressPair(transactionType: .transfer,
                                       address: "0x98122427eE193fAcbb9Fbdbf6BDE7d9042A95a0f"),
            TransactionTypeAddressPair(transactionType: .changePubKeyECDSA,
                                       address: ethSigner.address)
        ]

        let batch = TransactionFeeBatchRequest(transactionsAndAddresses: transactions,
                                               tokenIdentifier: Token.ETH.address)

        let exp = expectation(description: "transactionFeeBatch")

        var finalResult: PromiseKit.Result<TransactionFeeDetails>?

        firstly {
            self.wallet.provider.transactionFeePromise(request: batch)
        }.pipe { (result) in
            finalResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)

        switch finalResult {
        case .fulfilled(let transactionFeeDetails):
            NSLog("Transaction fee details: \(transactionFeeDetails).")
        case .rejected(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }

    func test_14_GetTokenPrice() {
        let exp = expectation(description: "getTokenPrice")

        var finalResult: Swift.Result<Decimal, Error>?
        self.wallet.provider.tokenPrice(token: .ETH) { (result) in
            finalResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)

        switch finalResult {
        case .success(let tokenPrice):
            NSLog("Token price: \(tokenPrice).")
        case .failure(let error):
            XCTFail("\(error)")
        default:
            break
        }
    }

    func test_15_GetConfirmationsForEthOpAmount() {
        let exp = expectation(description: "getConfirmationsForEthOpAmount")
        var finalResult: Swift.Result<UInt64, Error>?
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

    func test_16_Enable2FA() {
        let exp = expectation(description: "enable2FA")
        var finalResult: Swift.Result<Toggle2FAInfo, Error>?

        do {
            try self.wallet.enable2FA { result in
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
        } catch {
            XCTFail("Failed with error: \(error.localizedDescription)")
        }
    }

    func test_17_Disable2FA() {
        let exp = expectation(description: "disable2FA")
        var finalResult: Swift.Result<Toggle2FAInfo, Error>?

        do {
            try self.wallet.disable2FA { result in
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
        } catch {
            XCTFail("Failed with error: \(error.localizedDescription)")
        }
    }
    // swiftlint:disable:next file_length
}

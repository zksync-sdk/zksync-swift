//
//  IntegrationCreate2ShortFlowTests.swift
//  ZKSyncExampleTests
//
//  Created by Maxim Makhun on 9/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import ZKSync
import web3swift_zksync
import PromiseKit

class IntegrationCreate2ShortFlowTests: XCTestCase {

    let queue = DispatchQueue.global(qos: .default)

    // swiftlint:disable:next function_body_length
    func testSetupPublicKey() {
        do {
            let seed = Data(hex: "0x" + [UInt8](repeating: 0, count: 32).toHexString())
            let zkSigner = try ZkSigner(seed: seed)

            let creatorAddress = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"
            let salt = "0x" + [UInt8](repeating: 0, count: 32).toHexString()
            let codeHash = "0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"
            let create2Data = ChangePubKeyCREATE2(creatorAddress: creatorAddress,
                                                  saltArg: salt,
                                                  codeHash: codeHash)

            let ethSigner = try Create2EthSigner(zkSigner: zkSigner, create2Data: create2Data)
            let provider = DefaultProvider(chainId: .rinkeby)
            let wallet = try DefaultWallet<ChangePubKeyCREATE2, Create2EthSigner>(ethSigner: ethSigner,
                                                                                  zkSigner: zkSigner,
                                                                                  provider: provider)

            let pollInterval = DispatchTimeInterval.milliseconds(100)
            let pollingTransactionReceiptProcessor = PollingTransactionReceiptProcessor(provider,
                                                                                        pollInterval: pollInterval,
                                                                                        attempts: 50)

            var finalResult: PromiseKit.Result<String>?

            let exp = self.expectation(description: "")

            firstly {
                wallet.provider.transactionFeePromise(for: .changePubKeyCREATE2,
                                                      address: wallet.address,
                                                      tokenIdentifier: Token.ETH.address)
                    .map(on: self.queue) { ($0) }
            }.then(on: queue) { (feeDetails) in
                wallet.getNonce()
                    .map(on: self.queue) { ($0, feeDetails) }
            }.then(on: queue) { (nonce, feeDetails) -> Promise<String> in
                let fee = TransactionFee(feeToken: Token.ETH.address,
                                         fee: feeDetails.totalFeeInteger)

                let timeRange = TimeRange(validFrom: 0, validUntil: 4294967295)
                var changePubKey = ChangePubKey<ChangePubKeyCREATE2>(accountId: wallet.accountId!,
                                                                     account: wallet.address,
                                                                     newPkHash: zkSigner.publicKeyHash,
                                                                     feeToken: Token.ETH.id,
                                                                     fee: fee.fee.description,
                                                                     nonce: nonce,
                                                                     timeRange: timeRange)

                changePubKey.ethAuthData = create2Data

                NSLog("ChangePubKey: \(changePubKey).")

                changePubKey = try ethSigner.signAuth(changePubKey: changePubKey)

                let ethSignature = try ethSigner.signTransaction(transaction: changePubKey,
                                                                 nonce: changePubKey.nonce,
                                                                 token: Token.ETH,
                                                                 fee: changePubKey.feeInteger)

                let signedTransaction = SignedTransaction(transaction: try zkSigner.sign(changePubKey: changePubKey),
                                                          ethereumSignature: ethSignature)

                return wallet.submitSignedTransaction(signedTransaction.transaction,
                                                      ethereumSignature: ethSignature,
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
                pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
            }.pipe {
                transactionDetailsResult = $0
                transactionReceiptExpectation.fulfill()
            }

            wait(for: [transactionReceiptExpectation], timeout: 60.0)

            switch transactionDetailsResult {
            case .fulfilled(let transactionDetails):
                NSLog("Transaction details: \(transactionDetails)")
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
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    // swiftlint:disable:next function_body_length
    func testTransferFunds() {
        do {
            let seed = Data(hex: "0x" + [UInt8](repeating: 0, count: 32).toHexString())
            let zkSigner = try ZkSigner(seed: seed)

            let creatorAddress = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"
            let salt = "0x" + [UInt8](repeating: 0, count: 32).toHexString()
            let codeHash = "0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"
            let create2Data = ChangePubKeyCREATE2(creatorAddress: creatorAddress,
                                                  saltArg: salt,
                                                  codeHash: codeHash)

            let ethSigner = try Create2EthSigner(zkSigner: zkSigner, create2Data: create2Data)
            let provider = DefaultProvider(chainId: .rinkeby)
            let wallet = try DefaultWallet<ChangePubKeyCREATE2, Create2EthSigner>(ethSigner: ethSigner,
                                                                                  zkSigner: zkSigner,
                                                                                  provider: provider)

            let pollInterval = DispatchTimeInterval.milliseconds(100)
            let pollingTransactionReceiptProcessor = PollingTransactionReceiptProcessor(provider,
                                                                                        pollInterval: pollInterval,
                                                                                        attempts: 50)

            var finalResult: PromiseKit.Result<String>?

            let exp = self.expectation(description: "")

            firstly {
                wallet.provider.transactionFeePromise(for: .transfer,
                                                      address: ethSigner.address,
                                                      tokenIdentifier: Token.ETH.address)
                    .map(on: self.queue) { ($0) }
            }.then(on: queue) { (feeDetails) in
                wallet.getNonce()
                    .map(on: self.queue) { ($0, feeDetails) }
            }.then(on: queue) { (nonce, feeDetails) -> Promise<String> in
                let fee = TransactionFee(feeToken: Token.ETH.address,
                                         fee: feeDetails.totalFeeInteger)

                let timeRange = TimeRange(validFrom: 0, validUntil: 4294967295)
                let transfer = Transfer(accountId: wallet.accountId!,
                                        from: ethSigner.address,
                                        to: ethSigner.address,
                                        token: Token.ETH.id,
                                        amount: Web3.Utils.parseToBigUInt("100000", units: .Gwei)!,
                                        fee: fee.fee.description,
                                        nonce: nonce,
                                        timeRange: timeRange)

                NSLog("Transfer: \(transfer.description)")

                // It's expected for `Create2EthSigner` to return nil when calling:
                // `Create2EthSigner.signTransaction(transaction:nonce:token:fee:)`.
                let ethSignature = try ethSigner.signTransaction(transaction: transfer,
                                                                 nonce: transfer.nonce,
                                                                 token: Token.ETH,
                                                                 fee: fee.fee)

                let signedTransaction = SignedTransaction(transaction: try zkSigner.sign(transfer: transfer),
                                                          ethereumSignature: ethSignature)

                return wallet.submitSignedTransaction(signedTransaction.transaction,
                                                      ethereumSignature: ethSignature,
                                                      fastProcessing: false)
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

            guard let txHash = try? finalResult?.result.get() else {
                XCTFail("Hash should be valid.")
                return
            }

            var transactionDetailsResult: PromiseKit.Result<ZKSync.TransactionDetails>?

            let transactionReceiptExpectation = expectation(description: "Transaction expectation")
            firstly {
                pollingTransactionReceiptProcessor.waitForTransaction(txHash, transactionStatus: .commited)
            }.pipe {
                transactionDetailsResult = $0
                transactionReceiptExpectation.fulfill()
            }

            wait(for: [transactionReceiptExpectation], timeout: 60.0)

            switch transactionDetailsResult {
            case .fulfilled(let transactionDetails):
                NSLog("Transaction details: \(transactionDetails)")
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
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

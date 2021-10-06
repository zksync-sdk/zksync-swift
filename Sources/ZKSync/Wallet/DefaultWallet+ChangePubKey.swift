//
//  DefaultWallet+ChangePubKey.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 16/01/2021.
//

//import Foundation
//import PromiseKit
//
//extension DefaultWallet {
//
//    public func setSigningKey(fee: TransactionFee,
//                              nonce: UInt32?,
//                              onchainAuth: Bool,
//                              timeRange: TimeRange,
//                              completion: @escaping (Swift.Result<String, Error>) -> Void) {
//
//        guard !isSigningKeySet else {
//            completion(.failure(WalletError.signingKeyAlreadySet))
//            return
//        }
//
//        let nonceAccountIdPairPromise = getNonceAccountIdPair(for: nonce)
//        var resultPromise: Promise<String>
//
//        if onchainAuth {
//            resultPromise = nonceAccountIdPairPromise.then { (nonce, accountId) in
//                self.buildSignedChangePubKeyTxOnchain(fee: fee,
//                                                      accountId: accountId,
//                                                      nonce: nonce,
//                                                      timeRange: timeRange)
//            }.then { signedTransaction in
//                self.submitSignedTransaction(signedTransaction.transaction,
//                                             ethereumSignature: signedTransaction.ethereumSignature,
//                                             fastProcessing: false)
//            }
//        } else {
//            resultPromise = nonceAccountIdPairPromise.then { (nonce, accountId) in
//                self.buildSignedChangePubKeyTx(fee: fee,
//                                               accountId: accountId,
//                                               nonce: nonce,
//                                               timeRange: timeRange)
//            }.then { signedTransaction in
//                self.submitSignedTransaction(signedTransaction.transaction,
//                                             ethereumSignature: signedTransaction.ethereumSignature,
//                                             fastProcessing: false)
//            }
//        }
//
//        resultPromise.pipe { result in
//            completion(result.result)
//        }
//    }
//
//    public func buildSignedChangePubKeyTxOnchain(fee: TransactionFee,
//                                                 accountId: UInt32,
//                                                 nonce: UInt32,
//                                                 // swiftlint:disable:next line_length
//                                                 timeRange: TimeRange) -> Promise<SignedTransaction<ChangePubKey<ChangePubKeyOnchain>>> {
//        return firstly {
//            getTokens()
//        }.map { tokens in
//            let token = try tokens.tokenByTokenIdentifier(fee.feeToken)
//            let changePubKey = ChangePubKey<ChangePubKeyOnchain>(accountId: accountId,
//                                                                 account: self.ethSigner.address,
//                                                                 newPkHash: self.zkSigner.publicKeyHash,
//                                                                 feeToken: token.id,
//                                                                 fee: fee.fee.description,
//                                                                 nonce: nonce,
//                                                                 timeRange: timeRange)
//
//            let transaction = try self.zkSigner.sign(changePubKey: changePubKey)
//            let signedTransaction = SignedTransaction(transaction: transaction,
//                                                      ethereumSignature: nil)
//            return signedTransaction
//        }
//    }
//
//    public func buildSignedChangePubKeyTx(fee: TransactionFee,
//                                          accountId: UInt32,
//                                          nonce: UInt32,
//                                          timeRange: TimeRange) -> Promise<SignedTransaction<ChangePubKey<S.A>>> {
//        return firstly {
//            getTokens()
//        }.map { tokens in
//            let token = try tokens.tokenByTokenIdentifier(fee.feeToken)
//            let changePubKey = ChangePubKey<S.A>(accountId: accountId,
//                                                 account: self.ethSigner.address,
//                                                 newPkHash: self.zkSigner.publicKeyHash,
//                                                 feeToken: token.id,
//                                                 fee: fee.fee.description,
//                                                 nonce: nonce,
//                                                 timeRange: timeRange)
//
//            let changePubKeyAuth = try self.ethSigner.signAuth(changePubKey: changePubKey)
//
//            let ethSignature = try self.ethSigner.signTransaction(transaction: changePubKey,
//                                                                  nonce: nonce,
//                                                                  token: token,
//                                                                  fee: fee.fee)
//
//            let transaction = try self.zkSigner.sign(changePubKey: changePubKeyAuth)
//            let signedTransaction = SignedTransaction(transaction: transaction,
//                                                      ethereumSignature: ethSignature)
//            return signedTransaction
//        }
//    }
//}

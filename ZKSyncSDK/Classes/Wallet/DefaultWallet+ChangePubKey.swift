//
//  DefaultWallet+ChangePubKey.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation
import PromiseKit
import BigInt

extension DefaultWallet {

    public func setSigningKey(fee: TransactionFee, nonce: UInt32?, oncahinAuth: Bool, timeRange: TimeRange, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        
        guard !isSigningKeySet else {
            completion(.failure(WalletError.signingKeyAlreadySet))
            return
        }
        
        let nonceAccountIdPairPromise = getNonceAccountIdPair(for: nonce)
        let resultPromise: Promise<String>
        
        if oncahinAuth {
            resultPromise = nonceAccountIdPairPromise.then { (nonce, accountId) in
                self.buildSignedChangePubKeyTxOnchain(fee: fee, accountId: accountId, nonce: nonce, timeRange: timeRange)
            }.then { signedTransaction in
                self.submitSignedTransaction(signedTransaction.transaction,
                                             ethereumSignature: signedTransaction.ethereumSignature,
                                             fastProcessing: false)
            }

        } else {
            resultPromise = nonceAccountIdPairPromise.then { (nonce, accountId) in
                self.buildSignedChangePubKeyTxSigned(fee: fee, accountId: accountId, nonce: nonce, timeRange: timeRange)
            }.then { signedTransaction in
                self.submitSignedTransaction(signedTransaction.transaction,
                                             ethereumSignature: signedTransaction.ethereumSignature,
                                             fastProcessing: false)
            }
        }
        
        resultPromise.pipe { result in
            completion(result.result)
        }
    }
    
    public func buildSignedChangePubKeyTxOnchain(fee: TransactionFee,
                                          accountId: UInt32,
                                          nonce: UInt32,
                                          timeRange: TimeRange) -> Promise<SignedTransaction<ChangePubKey<ChangePubKeyOnchain>>> {
        return firstly {
            getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(fee.feeToken)
            let changePubKey = ChangePubKey<ChangePubKeyOnchain>(accountId: accountId,
                                            account: self.ethSigner.address,
                                            newPkHash: self.zkSigner.publicKeyHash,
                                            feeToken: token.id,
                                            fee: fee.fee.description,
                                            nonce: nonce,
                                            timeRange: timeRange)
            
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(changePubKey: changePubKey), ethereumSignature: nil)
            return signedTransaction
        }
    }
    
    public func buildSignedChangePubKeyTxSigned(fee: TransactionFee,
                                          accountId: UInt32,
                                          nonce: UInt32,
                                          timeRange: TimeRange) -> Promise<SignedTransaction<ChangePubKey<ChangePubKeyECDSA>>> {
        return firstly {
            getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(fee.feeToken)
            let changePubKey = ChangePubKey<ChangePubKeyECDSA>(accountId: accountId,
                                            account: self.ethSigner.address,
                                            newPkHash: self.zkSigner.publicKeyHash,
                                            feeToken: token.id,
                                            fee: fee.fee.description,
                                            nonce: nonce,
                                            timeRange: timeRange)
            
            let batchHash = Data(repeating: 0, count: 32).toHexString().addHexPrefix()
            
            let auth = ChangePubKeyECDSA(ethSignature: nil, batchHash: batchHash)
            
            let ethSignature = try self.ethSigner.signChangePubKey(pubKeyHash: self.zkSigner.publicKeyHash,
                                                                   nonce: nonce,
                                                                   accountId: accountId,
                                                                   changePubKeyVariant: auth)
            
            changePubKey.ethAuthData = ChangePubKeyECDSA(ethSignature: ethSignature.signature,
                                                         batchHash: batchHash)
            
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(changePubKey: changePubKey), ethereumSignature: ethSignature)
            return signedTransaction
        }
    }

}

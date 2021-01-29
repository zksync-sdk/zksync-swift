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

    public func setSigningKey(fee: TransactionFee, nonce: UInt32?, oncahinAuth: Bool, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        
        guard !isSigningKeySet else {
            completion(.failure(WalletError.signingKeyAlreadySet))
            return
        }
        
        firstly {
            getNonceAccountIdPair(for: nonce)
        }.then { (nonce, accountId) in
            self.buildSignedChangePubKeyTx(fee: fee, accountId: accountId, nonce: nonce, onchainAuth: oncahinAuth)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: false)
        }.pipe { result in
            completion(result.result)
        }
    }
    
    public func buildSignedChangePubKeyTx(fee: TransactionFee,
                                          accountId: UInt32,
                                          nonce: UInt32,
                                          onchainAuth: Bool) -> Promise<SignedTransaction<ChangePubKey>> {
        return firstly {
            getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(fee.feeToken)
            let changePubKey = ChangePubKey(accountId: accountId,
                                            account: self.ethSigner.address,
                                            newPkHash: self.zkSigner.publicKeyHash,
                                            feeToken: token.id,
                                            fee: fee.fee.description,
                                            nonce: nonce)
            var ethSignature: EthSignature? = nil
            if !onchainAuth {
                ethSignature = try self.ethSigner.signChangePubKey(pubKeyHash: self.zkSigner.publicKeyHash,
                                                                   nonce: nonce,
                                                                   accountId: accountId)
                changePubKey.ethSignature = ethSignature?.signature
            }
            
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(changePubKey: changePubKey), ethereumSignature: ethSignature)
            return signedTransaction
        }
    }
}

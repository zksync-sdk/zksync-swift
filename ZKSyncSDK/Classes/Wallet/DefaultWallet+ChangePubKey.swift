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

    public func setSigningKey(fee: TransactionFee, nonce: Int32?, oncahinAuth: Bool, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        firstly {
            return nonce != nil ? .value(nonce!) : getNonce()
        }.then { nonce in
            self.buildSignedChangePubKeyTx(fee: fee, nonce: nonce, onchainAuth: oncahinAuth)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: false)
        }.pipe { result in
            completion(result.result)
        }
    }
    
    func buildSignedChangePubKeyTx(fee: TransactionFee,
                                   nonce: Int32,
                                   onchainAuth: Bool) -> Promise<SignedTransaction<ChangePubKey>> {
        return firstly {
            getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(fee.feeToken)
            var changePubKey = ChangePubKey(accountId: self.accountId,
                                            account: self.ethSigner.address,
                                            newPkHash: self.zkSigner.publicKeyHash,
                                            feeToken: token.id,
                                            fee: fee.fee.description,
                                            nonce: nonce)
            var ethSignature: EthSignature? = nil
            if !onchainAuth {
                ethSignature = try self.ethSigner.signChangePubKey(pubKeyHash: self.zkSigner.publicKeyHash,
                                                                   nonce: nonce,
                                                                   accountId: self.accountId)
                changePubKey.ethSignature = ethSignature?.signature
            }
            
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(changePubKey: changePubKey), ethereumSignature: ethSignature)
            return signedTransaction
        }
    }
}

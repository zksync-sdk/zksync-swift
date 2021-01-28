//
//  DefaultWallet+ForcedExit.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation
import PromiseKit
import BigInt

extension DefaultWallet {
    
    public func forcedExit(target: String, fee: TransactionFee, nonce: UInt32?, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        firstly {
            return nonce != nil ? .value(nonce!) : getNonce()
        }.then { nonce in
            self.buildSignedForcedExitTx(target: target, tokenIdentifier: fee.feeToken, fee: fee.fee, nonce: nonce)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: false)
        }.pipe { result in
            completion(result.result)
        }
    }
    
    public func buildSignedForcedExitTx(target: String,
                                 tokenIdentifier: String,
                                 fee: BigUInt,
                                 nonce: UInt32) -> Promise<SignedTransaction<ForcedExit>> {
        return firstly {
            getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(tokenIdentifier)
            let forcedExit = ForcedExit(initiatorAccountId: self.accountId,
                                        target: target,
                                        token: token.id,
                                        fee: fee.description,
                                        nonce: nonce)
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(forcedExit: forcedExit), ethereumSignature: nil)
            return signedTransaction
        }
    }
}

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
    
    public func forcedExit(target: String, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        firstly {
            getNonceAccountIdPair(for: nonce)
        }.then { (nonce, accountId: UInt32)  in
            self.buildSignedForcedExitTx(target: target, tokenIdentifier: fee.feeToken, fee: fee.fee, accountId: accountId, nonce: nonce, timeRange: timeRange)
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
                                        accountId: UInt32,
                                        nonce: UInt32,
                                        timeRange: TimeRange) -> Promise<SignedTransaction<ForcedExit>> {
        return firstly {
            getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(tokenIdentifier)
            let forcedExit = ForcedExit(initiatorAccountId: accountId,
                                        target: target,
                                        token: token.id,
                                        fee: fee.description,
                                        nonce: nonce,
                                        timeRange: timeRange)
            let ethSignature = try self.ethSigner.signForcedExit(to: target, nonce: nonce, token: token, fee: fee)
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(forcedExit: forcedExit), ethereumSignature: ethSignature)
            return signedTransaction
        }
    }
}

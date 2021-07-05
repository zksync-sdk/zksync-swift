//
//  DefaultWallet+Transfer.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation
import PromiseKit
import BigInt

extension DefaultWallet {
    
    public func transfer(to: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        
        firstly {
            getNonceAccountIdPair(for: nonce)
        }.then { (nonce, accountId) in
            self.buildSignedTransferTx(to: to,
                                       tokenIdentifier: fee.feeToken,
                                       amount: amount,
                                       fee: fee.fee,
                                       accountId: accountId,
                                       nonce: nonce,
                                       timeRange: timeRange)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: false)
        }.pipe { result in
            completion(result.result)
        }
    }
    
    public func buildSignedTransferTx(to: String,
                                      tokenIdentifier: String,
                                      amount: BigUInt,
                                      fee: BigUInt,
                                      accountId: UInt32,
                                      nonce: UInt32,
                                      timeRange: TimeRange) -> Promise<SignedTransaction<Transfer>> {
        return firstly {
            getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(tokenIdentifier)
            let transfer = Transfer(accountId: accountId,
                                    from: self.ethSigner.address,
                                    to: to,
                                    token: token.id,
                                    amount: amount,
                                    fee: fee.description,
                                    nonce: nonce,
                                    timeRange: timeRange)
            let ethSignature = try self.ethSigner.signTransfer(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee)
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(transfer: transfer), ethereumSignature: ethSignature)
            return signedTransaction
        }
    }
}

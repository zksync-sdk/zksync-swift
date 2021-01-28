//
//  DefaultWallet+Withdraw.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation
import PromiseKit
import BigInt

extension DefaultWallet {

    public func withdraw(ethAddress: String, amount: BigUInt, fee: TransactionFee, nonce: UInt32?, fastProcessing: Bool, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        
        firstly {
            return nonce != nil ? .value(nonce!) : getNonce()
        }.then { nonce in
            self.buildSignedWithdrawTx(to: ethAddress,
                                       tokenIdentifier: fee.feeToken,
                                       amount: amount,
                                       fee: fee.fee,
                                       nonce: nonce)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: fastProcessing)
        }.pipe { result in
            completion(result.result)
        }
    }
    
    public func buildSignedWithdrawTx(to: String,
                                      tokenIdentifier: String,
                                      amount: BigUInt,
                                      fee: BigUInt,
                                      nonce: UInt32) -> Promise<SignedTransaction<Withdraw>> {

        return firstly {
            self.getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(tokenIdentifier)
            let withdraw = Withdraw(accountId: self.accountId,
                                    from: self.ethSigner.address,
                                    to: to,
                                    token: token.id,
                                    amount: amount,
                                    fee: fee.description,
                                    nonce: nonce)
            let ethSignature = try self.ethSigner.signWithdraw(to: to, accountId: self.accountId, nonce: nonce, amount: amount, token: token, fee: fee)
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(withdraw: withdraw), ethereumSignature: ethSignature)
            return signedTransaction
        }
    }
}

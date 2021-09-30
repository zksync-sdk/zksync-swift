//
//  DefaultWallet+Withdraw.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 16/01/2021.
//

import Foundation
import PromiseKit
import BigInt

extension DefaultWallet {

    // swiftlint:disable:next function_parameter_count
    public func withdraw(ethAddress: String,
                         amount: BigUInt,
                         fee: TransactionFee,
                         nonce: UInt32?,
                         fastProcessing: Bool,
                         timeRange: TimeRange,
                         completion: @escaping (Swift.Result<String, Error>) -> Void) {
        firstly {
            getNonceAccountIdPair(for: nonce)
        }.then { (nonce, accountId) in
            self.buildSignedWithdrawTx(to: ethAddress,
                                       tokenIdentifier: fee.feeToken,
                                       amount: amount,
                                       fee: fee.fee,
                                       accountId: accountId,
                                       nonce: nonce,
                                       timeRange: timeRange)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: fastProcessing)
        }.pipe { result in
            completion(result.result)
        }
    }

    // swiftlint:disable:next function_parameter_count
    public func buildSignedWithdrawTx(to: String,
                                      tokenIdentifier: String,
                                      amount: BigUInt,
                                      fee: BigUInt,
                                      accountId: UInt32,
                                      nonce: UInt32,
                                      timeRange: TimeRange) -> Promise<SignedTransaction<Withdraw>> {
        return firstly {
            self.getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(tokenIdentifier)
            let withdraw = Withdraw(accountId: accountId,
                                    from: self.ethSigner.address,
                                    to: to,
                                    token: token.id,
                                    amount: amount,
                                    fee: fee.description,
                                    nonce: nonce,
                                    timeRange: timeRange)

            let ethSignature = try self.ethSigner.signTransaction(transaction: withdraw,
                                                                  nonce: nonce,
                                                                  token: token,
                                                                  fee: fee)

            let transaction = try self.zkSigner.sign(withdraw: withdraw)
            let signedTransaction = SignedTransaction(transaction: transaction,
                                                      ethereumSignature: ethSignature)
            return signedTransaction
        }
    }
}

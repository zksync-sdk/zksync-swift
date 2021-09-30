//
//  DefaultWallet+Swap.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 23/05/2021.
//

import Foundation
import BigInt
import PromiseKit

extension DefaultWallet {

    // swiftlint:disable:next function_parameter_count
    public func swap(order1: Order,
                     order2: Order,
                     amount1: BigUInt,
                     amount2: BigUInt,
                     fee: TransactionFee,
                     nonce: UInt32?,
                     completion: @escaping (Swift.Result<String, Error>) -> Void) {
        firstly {
            getNonceAccountIdPair(for: nonce)
        }.then { (nonce, accountId) in
            self.buildSignedSwapTx(order1: order1,
                                   order2: order2,
                                   amount1: amount1,
                                   amount2: amount2,
                                   fee: fee,
                                   accountId: accountId,
                                   nonce: nonce)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: false)
        }.pipe { result in
            completion(result.result)
        }
    }

    // swiftlint:disable:next function_parameter_count
    public func buildSignedSwapTx(order1: Order,
                                  order2: Order,
                                  amount1: BigUInt,
                                  amount2: BigUInt,
                                  fee: TransactionFee,
                                  accountId: UInt32,
                                  nonce: UInt32) -> Promise<SignedTransaction<Swap>> {
        return firstly {
            self.getTokens()
        }.map { tokens in
            let feeToken = try tokens.tokenByTokenIdentifier(fee.feeToken)
            let swap = Swap(submitterId: accountId,
                            submitterAddress: self.ethSigner.address,
                            nonce: nonce,
                            orders: (order1, order2),
                            amounts: (amount1, amount2),
                            fee: fee.fee.description,
                            feeToken: feeToken.id)

            let ethSignature = try self.ethSigner.signTransaction(transaction: swap,
                                                                  nonce: nonce,
                                                                  token: feeToken,
                                                                  fee: fee.fee)

            let transaction = try self.zkSigner.sign(swap: swap)
            return SignedTransaction(transaction: transaction,
                                     ethereumSignature: ethSignature)
        }
    }
}

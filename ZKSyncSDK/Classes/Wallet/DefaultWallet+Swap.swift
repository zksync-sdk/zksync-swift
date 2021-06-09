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

    public func swap(order1: Order, order2: Order, amount1: BigUInt, amount2: BigUInt, fee: TransactionFee, nonce: UInt32?, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        
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

    public func buildSignedSwapTx(order1: Order, order2: Order, amount1: BigUInt, amount2: BigUInt, fee: TransactionFee, accountId: UInt32, nonce: UInt32) -> Promise<SignedTransaction<Swap>> {
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
            let ethSignature = try self.ethSigner.signSwap(nonce: nonce, token: feeToken, fee: fee.fee)
            return SignedTransaction(transaction: try self.zkSigner.sign(swap: swap), ethereumSignature: ethSignature)
        }
    }
    
    public func buildSignedOrder(recepient: String, sell: Token, buy: Token, ratio: (BigUInt, BigUInt), amount: BigUInt, accountId: UInt32, nonce: UInt32, timeRange: TimeRange) throws -> Order {
        
        var order = Order(accountId: accountId,
                          recepientAddress: recepient,
                          nonce: nonce,
                          tokenBuy: buy.id,
                          tokenSell: sell.id,
                          ratio: ratio,
                          amount: amount,
                          timeRange: timeRange)
        let ethSignature = try ethSigner.signOrder(order, tokenSell: sell, tokenBuy: buy)
        order.ethereumSignature = ethSignature
        
        return try self.zkSigner.sign(order: order)
    }
}

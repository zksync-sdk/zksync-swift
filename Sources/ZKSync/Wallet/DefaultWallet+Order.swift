//
//  DefaultWallet+Order.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 09/06/2021.
//

import Foundation
import BigInt

extension DefaultWallet {

    // swiftlint:disable:next function_parameter_count
    public func buildSignedOrder(recepient: String,
                                 sell: Token,
                                 buy: Token,
                                 ratio: (BigUInt, BigUInt),
                                 amount: BigUInt,
                                 nonce: UInt32,
                                 timeRange: TimeRange) throws -> Order {

        guard let accountId = self.accountId else {
            throw DefaultWalletError.noAccountId
        }

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

//
//  DefaultWallet+Order.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 09/06/2021.
//

import Foundation
import BigInt

extension DefaultWallet {
    
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


//
//  Order.swift
//  ZKSyncExample
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension Order: Equatable {

    static var defaultOrder: Order {
        var order = Order(accountId: 6,
                          recepientAddress: "0x823b6a996cea19e0c41e250b20e2e804ea72ccdf",
                          nonce: 18,
                          tokenBuy: 2,
                          tokenSell: 0,
                          ratio: (1, 2),
                          amount: 1000000,
                          timeRange: .max)
        // swiftlint:disable:next line_length
        order.ethereumSignature = EthSignature(signature: "0x841a4ed62572883b2272a56164eb33f7b0649029ba588a7230928cff698b49383045b47d35dcdee1beb33dd4ca6b944b945314a206f3f2838ddbe389a34fc8cb1c",
                                               type: .ethereumSignature)

        order.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                    // swiftlint:disable:next line_length
                                    signature: "b76c83011ea9e14cf679d35b9a7084832a78bf3f975c5b5c3315f80993c227afb7a1cd7e7b8fc225a48d8c9be78335736115890df5bbacfc52ecf47b4e089500")

        return order
    }

    static var defaultOrderA: Order {
        return Order(accountId: 6,
                     recepientAddress: "0x823b6a996cea19e0c41e250b20e2e804ea72ccdf",
                     nonce: 18,
                     tokenBuy: 2,
                     tokenSell: 1,
                     ratio: (1, 2),
                     amount: 1000000,
                     timeRange: .max)
    }

    static var defaultOrderB: Order {
        return Order(accountId: 44,
                     recepientAddress: "0x63adbb48d1bc2cf54562910ce54b7ca06b87f319",
                     nonce: 101,
                     tokenBuy: 1,
                     tokenSell: 2,
                     ratio: (3, 1),
                     amount: 2500000,
                     timeRange: .max)
    }

    public static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.recepientAddress == rhs.recepientAddress &&
            lhs.nonce == rhs.nonce &&
            lhs.tokenBuy == rhs.tokenBuy &&
            lhs.tokenSell == rhs.tokenSell &&
            lhs.ratio == rhs.ratio &&
            lhs.amount == rhs.amount &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.ethereumSignature == rhs.ethereumSignature
    }
}

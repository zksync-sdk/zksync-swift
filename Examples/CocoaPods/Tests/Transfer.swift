//
//  Transfer.swift
//  ZKSyncExampleTests
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension Transfer: Equatable {

    static var defaultTX: Transfer {
        let defaultTX = Transfer(accountId: 44,
                                 from: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                                 to: "0x19aa2ed8712072e918632259780e587698ef58df",
                                 token: 0,
                                 amount: 1000000000000,
                                 fee: "1000000",
                                 nonce: 12,
                                 timeRange: .max)
        defaultTX.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                        // swiftlint:disable:next line_length
                                        signature: "b3211c7e15d31d64619e0c7f65fce8c6e45637b5cfc8711478c5a151e6568d875ec7f48e040225fe3cc7f1e7294625cad6d98b4595d007d36ef62122de16ae01")
        return defaultTX
    }

    public static func == (lhs: Transfer, rhs: Transfer) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.from == rhs.from &&
            lhs.to == rhs.to &&
            lhs.token == rhs.token &&
            lhs.amount == rhs.amount &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }
}

//
//  Withdraw.swift
//  ZKSyncExampleTests
//
//  Created by Maksim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension Withdraw: Equatable {

    static var defaultTX: Withdraw {
        let withdraw = Withdraw(accountId: 44,
                                from: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                                to: "0x19aa2ed8712072e918632259780e587698ef58df",
                                token: 0,
                                amount: 1000000000000,
                                fee: "1000000",
                                nonce: 12,
                                timeRange: .max)
        withdraw.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                       // swiftlint:disable:next line_length
                                       signature: "11dc47fced9e6ffabe33112a4280c02d0c1ffa649ba3843eec256d427b90ed82e495c0cee2138d5a9e20328d31cb97b70d7e2ede0d8d967678803f4b5896f701")
        return withdraw
    }

    public static func == (lhs: Withdraw, rhs: Withdraw) -> Bool {
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

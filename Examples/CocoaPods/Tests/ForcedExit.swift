//
//  ForcedExit.swift
//  ZKSyncExampleTests
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension ForcedExit: Equatable {

    static var defaultTX: ForcedExit {
        let forcedExit = ForcedExit(initiatorAccountId: 44,
                                    target: "0x19aa2ed8712072e918632259780e587698ef58df",
                                    token: 0,
                                    fee: "1000000",
                                    nonce: 12,
                                    timeRange: .max)
        forcedExit.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                         // swiftlint:disable:next line_length
                                         signature: "b1b82f7ac37e2d4bd675e4a5cd5e48d9fad1739282db8a979c3e4d9e39d794915667ee2c125ba24f4fe81ad6d19491eef0be849a823ea6567517b7e207214705")
        return forcedExit
    }

    public static func == (lhs: ForcedExit, rhs: ForcedExit) -> Bool {
        return lhs.initiatorAccountId == rhs.initiatorAccountId &&
            lhs.target == rhs.target &&
            lhs.token == rhs.token &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }
}

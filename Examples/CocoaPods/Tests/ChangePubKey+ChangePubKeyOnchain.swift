//
//  ChangePubKey.swift
//  ZKSyncExample
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension ChangePubKey: Equatable where T == ChangePubKeyOnchain {

    static var defaultTX: ChangePubKey<ChangePubKeyOnchain> {
        let changePubKey = ChangePubKey<ChangePubKeyOnchain>(accountId: 55,
                                                             account: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                                                             newPkHash: "sync:18e8446d7748f2de52b28345bdbc76160e6b35eb",
                                                             feeToken: 0,
                                                             fee: "1000000000",
                                                             nonce: 13,
                                                             timeRange: TimeRange(validFrom: 0, validUntil: 4294967295))
        changePubKey.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                           // swiftlint:disable:next line_length
                                           signature: "85782959384c1728192b0fe9466a4273b6d0e78e913eea894b780e0236fc4c9d673d3833e895bce992fc113a4d16bba47ef73fed9c4fca2af09ed06cd6885802")
        changePubKey.ethAuthData = ChangePubKeyOnchain()

        return changePubKey
    }

    public static func == (lhs: ChangePubKey<T>, rhs: ChangePubKey<T>) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.account == rhs.account &&
            lhs.newPkHash == rhs.newPkHash &&
            lhs.feeToken == rhs.feeToken &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }
}

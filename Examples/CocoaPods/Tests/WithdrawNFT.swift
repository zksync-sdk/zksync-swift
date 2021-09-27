//
//  WithdrawNFT.swift
//  ZKSyncExampleTests
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension WithdrawNFT: Equatable {

    static var defaultTX: WithdrawNFT {
        let withdrawNFT = WithdrawNFT(accountId: 44,
                                      from: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                                      to: "0x19aa2ed8712072e918632259780e587698ef58df",
                                      token: 100000,
                                      feeToken: 0,
                                      fee: "1000000",
                                      nonce: 12,
                                      timeRange: .max)
        withdrawNFT.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                          // swiftlint:disable:next line_length
                                          signature: "1236180fe01b42c0c3c084d152b0582e714fa19da85900777e811f484a5b3ea434af320f66c7c657a33024d7be22cea44b7406d0af88c097a9d7d6b5d7154d02")
        return withdrawNFT
    }

    public static func == (lhs: WithdrawNFT, rhs: WithdrawNFT) -> Bool {
        return lhs.accountId == rhs.accountId &&
            lhs.from == rhs.from &&
            lhs.to == rhs.to &&
            lhs.token == rhs.token &&
            lhs.feeToken == rhs.feeToken &&
            lhs.fee == rhs.fee &&
            lhs.nonce == rhs.nonce &&
            lhs.timeRange.validFrom == rhs.timeRange.validFrom &&
            lhs.timeRange.validUntil == rhs.timeRange.validUntil &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }
}

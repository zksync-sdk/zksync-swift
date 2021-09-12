//
//  Swap.swift
//  ZKSyncExampleTests
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension Swap: Equatable {

    static var defaultTX: Swap {
        return Swap(submitterId: 5,
                    submitterAddress: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                    nonce: 1,
                    orders: (Order.defaultOrderA, Order.defaultOrderB),
                    amounts: (1000000, 2500000),
                    fee: "123",
                    feeToken: 3,
                    signature: Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                         // swiftlint:disable:next line_length
                                         signature: "c13aabacf96448efb47763554753bfe2acc303a8297c8af59e718d685d422a901a43c42448f95cca632821df1ccb754950196e8444c0acef253c42c1578b5401"))
    }

    public static func == (lhs: Swap, rhs: Swap) -> Bool {
        return lhs.submitterId == rhs.submitterId &&
            lhs.submitterAddress == rhs.submitterAddress &&
            lhs.nonce == rhs.nonce &&
            lhs.orders == rhs.orders &&
            lhs.amounts == rhs.amounts &&
            lhs.fee == rhs.fee &&
            lhs.feeToken == rhs.feeToken &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }
}

//
//  Toggle2FA.swift
//  ZKSync
//
//  Created by Maxim Makhun on 8/25/21.
//

import Foundation

public struct Toggle2FA: Encodable {

    public var enable: Bool

    public var accountId: UInt32

    public var timestamp: Int64

    public var signature: EthSignature

    public init(
        enable: Bool,
        accountId: UInt32,
        timestamp: Int64,
        signature: EthSignature
    ) {
        self.enable = enable
        self.accountId = accountId
        self.timestamp = timestamp
        self.signature = signature
    }
}

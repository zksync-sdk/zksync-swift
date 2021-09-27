//
//  EthSignature.swift
//  ZKSyncExampleTests
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension EthSignature: Equatable {

    public static func == (lhs: EthSignature, rhs: EthSignature) -> Bool {
        return lhs.signature == rhs.signature &&
            lhs.type == lhs.type
    }
}

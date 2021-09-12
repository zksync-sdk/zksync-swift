//
//  AccountState.swift
//  ZKSyncExample
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ZKSync

extension AccountState: Equatable {

    public static func == (lhs: AccountState, rhs: AccountState) -> Bool {
        return lhs.address == rhs.address &&
            lhs.id == rhs.id &&
            lhs.depositing == rhs.depositing &&
            lhs.committed == rhs.committed &&
            lhs.verified == rhs.verified
    }
}

extension AccountState.Depositing: Equatable {

    public static func == (lhs: AccountState.Depositing, rhs: AccountState.Depositing) -> Bool {
        return lhs.balances == rhs.balances
    }
}

extension AccountState.Balance: Equatable {

    public static func == (lhs: AccountState.Balance, rhs: AccountState.Balance) -> Bool {
        return lhs.amount == rhs.amount &&
            lhs.expectedAcceptBlock == rhs.expectedAcceptBlock
    }
}

extension AccountState.State: Equatable {

    public static func == (lhs: AccountState.State, rhs: AccountState.State) -> Bool {
        return lhs.nonce == rhs.nonce &&
            lhs.pubKeyHash == rhs.pubKeyHash &&
            lhs.balances == rhs.balances
    }
}

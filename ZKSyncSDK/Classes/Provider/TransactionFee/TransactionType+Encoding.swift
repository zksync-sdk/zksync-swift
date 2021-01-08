//
//  TransactionType+Encoding.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

extension TransactionType {
    var feeIdentifier: String {
        switch self {
        case .withdraw, .forcedExit:
            return "Withdraw"
        case .transfer:
            return "Transfer"
        case .fastWithdraw:
            return "FastWithdraw"
        case .changePubKey, .changePubKeyOnchainAuth:
            return  "ChangePubKey"
        }
    }
}

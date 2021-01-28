//
//  TransactionType.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

public enum TransactionType: String {
    case withdraw
    case transfer
    case fastWithdraw
    case changePubKey
    case changePubKeyOnchainAuth
    case forcedExit
}

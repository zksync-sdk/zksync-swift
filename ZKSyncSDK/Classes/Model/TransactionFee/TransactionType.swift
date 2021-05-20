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
    case changePubKeyOnchain
    case changePubKeyECDSA
    case changePubKeyCREATE2
    case legacyChangePubKey
    case legacyChangePubKeyOnchainAuth
    case forcedExit
    case swap
    case mintNFT
    case withdrawNFT
    case fastWithdrawNFT
}

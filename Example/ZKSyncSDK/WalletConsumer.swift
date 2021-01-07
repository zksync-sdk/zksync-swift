//
//  WalletConsumer.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 07/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ZKSyncSDK

protocol WalletConsumer {
    var wallet: Wallet! { get set }
}

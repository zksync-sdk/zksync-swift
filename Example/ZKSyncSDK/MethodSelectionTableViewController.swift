//
//  MethodSelectionTableViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 07/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSyncSDK

class MethodSelectionTableViewController: UITableViewController, WalletConsumer {
    var wallet: Wallet!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var destination = segue.destination as? WalletConsumer {
            destination.wallet = wallet
        }
    }
}

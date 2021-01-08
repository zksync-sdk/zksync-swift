//
//  TokenPriceViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 07/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSyncSDK

class TokenPriceViewController: UIViewController, WalletConsumer {

    var wallet: Wallet!
    
    @IBOutlet weak var tokenPriceLabel: UILabel!
    
    @IBAction func getTokenPRice(_ sender: Any) {
        wallet.getTokenPrice { (result) in
            switch result {
            case .success(let price):
                self.tokenPriceLabel.text = "\(price)"
            case .failure(_):
                break
            }
        }
    }
}

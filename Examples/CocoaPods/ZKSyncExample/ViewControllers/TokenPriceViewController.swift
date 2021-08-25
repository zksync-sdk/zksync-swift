//
//  TokenPriceViewController.swift
//  ZKSyncExample
//
//  Created by Eugene Belyakov on 07/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSync

class TokenPriceViewController: UIViewController, WalletConsumer {

    var wallet: Wallet!

    @IBOutlet weak var tokenPriceLabel: UILabel!

    @IBAction func getTokenPRice(_ sender: Any) {
        wallet.provider.tokenPrice(token: Token.ETH) { (result) in
            switch result {
            case .success(let price):
                self.tokenPriceLabel.text = "\(price)"
            case .failure(_):
                break
            }
        }
    }
}

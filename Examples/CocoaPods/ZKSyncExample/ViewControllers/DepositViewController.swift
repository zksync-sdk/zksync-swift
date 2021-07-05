//
//  DepositViewController.swift
//  ZKSyncExample
//
//  Created by Eugene Belyakov on 03/02/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSync
import web3swift
import BigInt
import PromiseKit

class DepositViewController: UIViewController, WalletConsumer {
    var wallet: Wallet!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBAction func deposit(_ sender: Any) {
        
        amountTextField.resignFirstResponder()
            
        guard let amountText = amountTextField.text,
              let amount = Web3.Utils.parseToBigUInt(amountText, units: .eth),
              amount > 0 else {
            
            self.showAmountError()
            return
        }
        
        let ethereumProvider = try! self.wallet.createEthereumProvider(web3: Web3.InfuraRinkebyWeb3())
        
        firstly {
            ethereumProvider.deposit(token: .ETH,
                                     amount: amount,
                                     userAddress: wallet.address)
        }.done { (result) in
            self.present(UIAlertController.for(message: "Successfully deposited"), animated: true, completion: nil)
        }.catch { (error) in
            self.present(UIAlertController.for(error: error), animated: true, completion: nil)
        }
    }
    
    func showAmountError() {
        self.present(UIAlertController.forIncorrectAmount(), animated: true, completion: nil)
    }
}



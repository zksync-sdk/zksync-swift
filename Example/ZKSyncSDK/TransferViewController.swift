//
//  TransferViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 03/02/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSyncSwift
import web3swift
import BigInt
import PromiseKit

class TransferViewController: UIViewController, WalletConsumer {

    var wallet: Wallet!

    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBAction func transfer(_ sender: Any) {
        
        amountTextField.resignFirstResponder()
            
        guard let amountText = amountTextField.text,
              let amount = Web3.Utils.parseToBigUInt(amountText, units: .eth),
              amount > 0 else {
            self.showAmountError()
            return
        }

        guard let address = addressTextField.text, !address.isEmpty else {
            self.showAddressError()
            return
        }

        firstly {
            self.wallet.getAccountStatePromise()
        }.then { state in
            self.wallet.provider.transactionFeePromise(for: .transfer,
                                                       address: address,
                                                       tokenIdentifier: Token.ETH.address).map { ($0, state) }
        }.then { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.transferPromise(to: address,
                                               amount: amount,
                                               fee: fee,
                                               nonce: nil)
        }.done { (result) in
            self.present(UIAlertController.for(message: "Successfully transferred"), animated: true, completion: nil)
        }.catch { (error) in
            self.present(UIAlertController.for(error: error), animated: true, completion: nil)
        }
    }
    
    func showAmountError() {
        self.present(UIAlertController.forIncorrectAmount(), animated: true, completion: nil)
    }
    
    func showAddressError() {
        self.present(UIAlertController.forIncorrectAddress(), animated: true, completion: nil)
    }
}

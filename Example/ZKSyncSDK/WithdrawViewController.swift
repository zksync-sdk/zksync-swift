//
//  WithdrawViewController.swift
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

class WithdrawViewController: UIViewController, WalletConsumer {

    var wallet: Wallet!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBAction func withdraw(_ sender: Any) {
        
        amountTextField.resignFirstResponder()
            
        guard let amountText = amountTextField.text,
              let amount = Web3.Utils.parseToBigUInt(amountText, units: .eth),
              amount > 0 else {
            self.showAmountError()
            return
        }

        firstly {
            self.wallet.getAccountStatePromise()
        }.then { state in
            self.wallet.provider.transactionFeePromise(
                for: .withdraw,
                address: state.address,
                tokenIdentifier: Token.ETH.address).map { ($0, state) }
        }.then { (feeDetails, state) -> Promise<String> in
            let fee = TransactionFee(feeToken: Token.ETH.address,
                                     fee: feeDetails.totalFeeInteger)
            return self.wallet.withdrawPromise(ethAddress: state.address,
                                               amount: amount,
                                               fee: fee,
                                               nonce: state.committed.nonce,
                                               fastProcessing: false)
        }.done { (result) in
            print("Successfully withdrawn")
        }.catch { (error) in
            print((error as NSError).localizedDescription)
        }
    }
    
    func showAmountError() {
        let alert = UIAlertController(title: "Error", message: "Incorrect amount", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

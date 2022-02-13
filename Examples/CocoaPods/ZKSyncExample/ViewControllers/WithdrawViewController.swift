//
//  WithdrawViewController.swift
//  ZKSyncExample
//
//  Created by Eugene Belyakov on 03/02/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSync
import web3swift
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
                                               fastProcessing: false,
                                               timeRange: TimeRange(validFrom: 0, validUntil: 4294967295))
        }.done { (_) in
            self.present(UIAlertController.for(message: "Successfully withdrawn"), animated: true, completion: nil)
        }.catch { (error) in
            self.present(UIAlertController.for(error: error), animated: true, completion: nil)
        }
    }

    func showAmountError() {
        self.present(UIAlertController.forIncorrectAmount(), animated: true, completion: nil)
    }
}

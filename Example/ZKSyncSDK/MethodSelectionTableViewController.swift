//
//  MethodSelectionTableViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 07/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSync
import PromiseKit
import web3swift

class MethodSelectionTableViewController: UITableViewController, WalletConsumer {
    var wallet: Wallet!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var ethBalanceLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var destination = segue.destination as? WalletConsumer {
            destination.wallet = wallet
        }
    }
    
    
    override func viewDidLoad() {
        
        self.wallet.getAccountState { (result) in
            self.updateBalances(state: try? result.get())
        }
    }
    
    private func weiToETH(string: String) -> String? {
        guard let value = Web3.Utils.parseToBigUInt(string, units: .wei) else {
            return nil
        }
        return Web3.Utils.formatToEthereumUnits(value)
    }
    
    private func updateBalances(state: AccountState?) {
        self.addressLabel.text = state?.address
        self.balanceLabel.text = weiToETH(string: state?.committed.balances["ETH"] ?? "0")
        let provider = try? self.wallet.createEthereumProvider(web3: Web3.InfuraRinkebyWeb3())
        provider?.getBalance().done { (value) in
            self.ethBalanceLabel.text = Web3.Utils.formatToEthereumUnits(value)
        }.catch { (error) in
            self.present(UIAlertController.for(error: error), animated: true, completion: nil)
        }
    }
    
    @IBAction func copyAddress(_ sender: Any) {
        UIPasteboard.general.string = self.addressLabel.text
    }
}

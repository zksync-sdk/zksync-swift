//
//  ContractAddressViewController.swift
//  ZKSyncExample
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import UIKit
import ZKSync

class ContractAddressViewController: UIViewController, WalletConsumer {

    var wallet: Wallet!

    @IBOutlet weak var mainContractLabel: UILabel!
    @IBOutlet weak var govContractLabel: UILabel!

    @IBAction func getContractAddress(_ sender: Any) {
        self.wallet.provider.contractAddress { result in
            switch result {
            case .success(let address):
                self.display(contractAddress: address)
            case .failure(let error):
                self.display(error: error)
            }
        }
    }

    private func display(contractAddress: ContractAddress) {
        self.mainContractLabel.text = contractAddress.mainContract
        self.govContractLabel.text = contractAddress.govContract
    }

    private func display(error: Error) {

    }
}

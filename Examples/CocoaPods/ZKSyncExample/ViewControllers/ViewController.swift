//
//  ContractAddressViewController.swift
//  ZKSyncExample
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import UIKit
import ZKSync

class ViewController: UIViewController, WalletConsumer {
    
    var wallet: Wallet!
    
    @IBOutlet weak var mainContractLabel: UILabel!
    @IBOutlet weak var govContractLabel: UILabel!
        
    @IBAction func getContractAddress(_ sender: Any) {
//        self.wallet.getContractAddress { result in
//            switch result {
//            case .success(let address):
//                self.display(contractAddress: address)
//            case .failure(let error):
//                self.display(error: error)
//            }
//        }
        
//        self.wallet.getAccountInfo { result in
//            switch result {
//            case .success(let state):
//                print(state)
//            case .failure(let error):
//                print(error)
//            }
//        }
        
//        self.wallet.getTokenPrice {
//            result in
//            switch result {
//            case .success(let price):
//                print(price)
//            case .failure(let error):
//                print(error)
//            }
//        }
        
//        self.wallet.getTransactionFee(for: .changePubKeyOnchainAuth, tokenIdentifier: Token.ETH.address) { (result) in
//            print(result)
//        }
    }
    
    private func display(contractAddress: ContractAddress) {
        self.mainContractLabel.text = contractAddress.mainContract
        self.govContractLabel.text = contractAddress.govContract
    }
    
    private func display(error: Error) {
        
    }
}


//
//  ViewController.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import UIKit
import ZKSyncSDK

class ViewController: UIViewController {
    
    var network: Network!
    
    var wallet: Wallet!
    
    @IBOutlet weak var mainContractLabel: UILabel!
    @IBOutlet weak var govContractLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wallet = DefaultWallet(transport: HTTPTransport(network: self.network))
    }
    
    @IBAction func getContractAddress(_ sender: Any) {
        self.wallet.getContractAddress { result in
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


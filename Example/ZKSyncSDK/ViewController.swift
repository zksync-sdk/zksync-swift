//
//  ViewController.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import UIKit
import ZKSyncSDK

class ViewController: UIViewController {
    
    var privateKey = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
    
    var network: Network!
    
    var wallet: Wallet!
    var ethSigner: EthSigner!
    
    @IBOutlet weak var mainContractLabel: UILabel!
    @IBOutlet weak var govContractLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWallet()
    }
    
    private func createWallet() {
        self.ethSigner = try? EthSigner(privateKey: self.privateKey)
        
        let transport = HTTPTransport(network: self.network)
        
        self.wallet = DefaultWallet(ethSigner: self.ethSigner,
                                    transport: transport)
    }
    
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
        
        self.wallet.getTokenPrice {
            result in
            switch result {
            case .success(let price):
                print(price)
            case .failure(let error):
                print(error)
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


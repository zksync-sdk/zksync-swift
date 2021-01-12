//
//  NetworkSelectionTableViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 06/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSyncSDK
import BigInt

class NetworkSelectionTableViewController: UITableViewController {
    
    var privateKey = "0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var network: Network = .localhost
        switch segue.identifier {
        case "MainnetSegue":
            network = .mainnet
        case "RinkebySegue":
            network = .rinkeby
        case "RopsteinSegue":
            network = .ropsten
        default:
            break
        }
        if var destination = segue.destination as? WalletConsumer {
            destination.wallet = createWallet(network)
        }
    }
    
    
    private func createWallet(_ network: Network) -> Wallet {
                
        guard let ethSigner = try? EthSigner(privateKey: self.privateKey) else {
            fatalError()
        }
        
        let transport = HTTPTransport(network: network)
        return DefaultWallet(ethSigner: ethSigner,
                             transport: transport)
    }
}

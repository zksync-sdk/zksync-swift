//
//  NetworkSelectionTableViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 06/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSyncSDK

class NetworkSelectionTableViewController: UITableViewController {
    
    var privateKey = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"

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
        let s = ethSigner.createChangePubKeyMessage(pubKeyHash: "sync:312467132468", nonce: 54, accountId: 23)
        
        let signature = try! ethSigner.sign(message: s)
        
        //try! s.data(using: .utf8)?.write(to: URL(fileURLWithPath: "/Users/eugene/message.txt"))
        
        let transport = HTTPTransport(network: network)
        return DefaultWallet(ethSigner: ethSigner,
                             transport: transport)
    }
}

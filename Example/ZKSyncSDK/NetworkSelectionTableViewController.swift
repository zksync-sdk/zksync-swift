//
//  NetworkSelectionTableViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 06/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSyncSwift
import BigInt

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
                
        guard let ethSigner = try? DefaultEthSigner(privateKey: self.privateKey) else {
            fatalError()
        }
        
        guard let zkSigner = try? ZkSigner(ethSigner: ethSigner, chainId: network.chainId) else {
            fatalError()
        }
        
        let transport = HTTPTransport(network: network)
        
        guard let wallet = try? DefaultWallet(ethSigner: ethSigner, zkSigner: zkSigner, transport: transport) else {
            fatalError()
        }
        
        return wallet
    }
}

extension Network {
    var chainId: ChainId {
        switch self {
        case .mainnet:
            return .mainnet
        case .localhost:
            return .localhost
        case .rinkeby:
            return .rinkeby
        case .ropsten:
            return .ropsten
        }
    }
}

//
//  NetworkSelectionTableViewController.swift
//  ZKSyncExample
//
//  Created by Eugene Belyakov on 06/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSync

class NetworkSelectionTableViewController: UITableViewController {

    var privateKey = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        var chainId: ChainId = .localhost
        switch segue.identifier {
        case "MainnetSegue":
            chainId = .mainnet
        case "RinkebySegue":
            chainId = .rinkeby
        case "RopsteinSegue":
            chainId = .ropsten
        default:
            break
        }
        if var destination = segue.destination as? WalletConsumer {
            destination.wallet = createWallet(chainId)
        }
    }

    private func createWallet(_ chainId: ChainId) -> Wallet {
        guard let ethSigner = try? DefaultEthSigner(privateKey: self.privateKey) else {
            fatalError()
        }

        var message = "Access zkSync account.\n\nOnly sign this message for a trusted client!"

        if chainId != .mainnet {
            message = "\(message)\nChain ID: \(chainId.id)."
        }

        guard let signature = try? ethSigner.sign(message: message.data(using: .utf8)!),
              let zkSigner = try? ZkSigner(signature: signature) else {
            fatalError()
        }

        let provider = DefaultProvider(chainId: chainId)

        guard let wallet = try? DefaultWallet<ChangePubKeyECDSA, DefaultEthSigner>(ethSigner: ethSigner,
                                                                                   zkSigner: zkSigner,
                                                                                   provider: provider) else {
            fatalError()
        }

        return wallet
    }
}

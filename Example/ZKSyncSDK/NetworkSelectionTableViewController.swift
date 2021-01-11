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

        let transport = HTTPTransport(network: network)
        return DefaultWallet(ethSigner: ethSigner,
                             transport: transport)

//        let amount = BigUInt("1000000000000") * BigUInt("1000000000000000000")
//        let fee = BigUInt("1000000") * BigUInt("1000000000000000000")
//
//        let s1 = try! ethSigner.createChangePubKeyMessage(pubKeyHash: "sync:18e8446d7748f2de52b28345bdbc76160e6b35eb", nonce: 13, accountId: 55)
//
//
//        let s2 = try! ethSigner.createTransferMessage(to: "0x19aa2ed8712072e918632259780e587698ef58df",
//                                                      accountId: 44,
//                                                      nonce: 12,
//                                                      amount: amount,
//                                                      token: Token.ETH,
//                                                      fee: fee)
//
//        let s3 = try ethSigner.createWithdrawMessage(to: "0x19aa2ed8712072e918632259780e587698ef58df",
//                                                     accountId: 44,
//                                                     nonce: 12,
//                                                     amount: amount,
//                                                     token: Token.ETH,
//                                                     fee: fee)
        
//        let signature = try! ethSigner.sign(message: s3)
        
        //try! s.data(using: .utf8)?.write(to: URL(fileURLWithPath: "/Users/eugene/message.txt"))
        
    }
}

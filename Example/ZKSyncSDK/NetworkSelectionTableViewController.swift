//
//  NetworkSelectionTableViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 06/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class NetworkSelectionTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "MainnetSegue":
            (segue.destination as? ViewController)?.network = .mainnet
        case "RinkebySegue":
            (segue.destination as? ViewController)?.network = .rinkeby
        case "RopsteinSegue":
            (segue.destination as? ViewController)?.network = .ropsten
        default:
            break
        }
    }
}

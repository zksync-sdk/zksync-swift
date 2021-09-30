//
//  ViewController.swift
//  ZKSyncExample
//
//  Created by Maxim Makhun on 6/27/21.
//

import UIKit
import ZKSync
import ZKSyncCrypto

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make sure that `ZKSync` symbols are available.
        let _: Wallet? = nil

        // Make sure that `ZKSyncCrypto` symbols are available.
        _ = ZKSyncCrypto.generatePrivateKey(seed: Data())
    }
}

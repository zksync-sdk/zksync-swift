//
//  ViewController.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import UIKit
import ZKSyncSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let provider = Provider(network: .rinkeby)
        provider.accountInfo(address: "ZkSyncSDK") { result in
            switch result {
            case .success(let data):
                print(data)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}


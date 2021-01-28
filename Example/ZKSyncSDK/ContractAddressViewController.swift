//
//  ContractAddressViewController.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import UIKit
import ZKSyncSDK

class ContractAddressViewController: UIViewController, WalletConsumer {
    
    var wallet: Wallet!
    
    @IBOutlet weak var mainContractLabel: UILabel!
    @IBOutlet weak var govContractLabel: UILabel!
        
    @IBAction func getContractAddress(_ sender: Any) {
        self.wallet.provider.contractAddress { result in
            switch result {
            case .success(let address):
                self.display(contractAddress: address)
            case .failure(let error):
                self.display(error: error)
            }
        }
        
//        let typesAndAddresses = [
//            TransactionTypeAddressPair(transactionType: .forcedExit, address: "0x98122427eE193fAcbb9Fbdbf6BDE7d9042A95a0f"),
//            TransactionTypeAddressPair(transactionType: .transfer, address: "0xC8568F373484Cd51FDc1FE3675E46D8C0dc7D246"),
//            TransactionTypeAddressPair(transactionType: .transfer, address: "0x98122427eE193fAcbb9Fbdbf6BDE7d9042A95a0f"),
//            TransactionTypeAddressPair(transactionType: .changePubKey, address: "0x98122427eE193fAcbb9Fbdbf6BDE7d9042A95a0f")]
//        
//        let request = TransactionFeeBatchRequest(transactionsAndAddresses: typesAndAddresses, tokenIdentifier: Token.ETH.address)
//        
//        self.wallet.getTransactionFee(for: request) { (result) in
//            
//        }
    }
    
    private func display(contractAddress: ContractAddress) {
        self.mainContractLabel.text = contractAddress.mainContract
        self.govContractLabel.text = contractAddress.govContract
    }
    
    private func display(error: Error) {
        
    }
}


//
//  ZkSync.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 19/01/2021.
//

import Foundation
import BigInt
import web3swift
import PromiseKit

enum ZkSyncContractError: Error {
    case invalidParameters
}

class ZkSync {
    
    var web3: web3
    var contractAddress: EthereumAddress
    var walletAddress: EthereumAddress
    
    init(web3: web3, contractAddress: EthereumAddress, walletAddress: EthereumAddress) {
        self.web3 = web3
        self.contractAddress = contractAddress
        self.walletAddress = walletAddress
    }

    lazy var contract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.zkSyncABI, at: self.contractAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    func depositETH(address: EthereumAddress, value: BigUInt) -> Promise<TransactionSendingResult> {
        guard let tx = self.contract.write("depositETH", parameters: [address] as [AnyObject] , transactionOptions: createOptions(value: value)) else {
            return Promise(error: ZkSyncContractError.invalidParameters)
        }
        return tx.sendPromise()
    }

    func depositERC20(tokenAddress: EthereumAddress, amount: BigUInt, userAddress: EthereumAddress) -> Promise<TransactionSendingResult> {
        
        guard let tx = self.contract.write("depositERC20", parameters: [tokenAddress, amount, userAddress] as [AnyObject], transactionOptions: createOptions()) else {
            return Promise(error: ZkSyncContractError.invalidParameters)
        }
        return tx.sendPromise()
    }

    func requestFullExit(tokenAddress: EthereumAddress, accountId: UInt32) -> Promise<TransactionSendingResult> {
        guard let tx = self.contract.write("requestFullExit", parameters: [accountId, tokenAddress] as [AnyObject], transactionOptions: createOptions()) else {
            return Promise(error: ZkSyncContractError.invalidParameters)
        }
        return tx.sendPromise()
    }
    
    func setAuthPubkeyHash(pubKeyHash: Data, nonce: UInt32) -> Promise<TransactionSendingResult> {
        guard let tx = self.contract.write("setAuthPubkeyHash", parameters: [pubKeyHash, nonce] as [AnyObject], transactionOptions: createOptions()) else {
            return Promise(error: ZkSyncContractError.invalidParameters)
        }
        return tx.sendPromise()
    }

    func authFacts(senderAddress: EthereumAddress, nonce: UInt32) -> Promise<Data> {
        
        guard let tx = self.contract.read("authFacts", parameters: [senderAddress, nonce] as [AnyObject], transactionOptions: createReadOptions()) else {
            return Promise(error: ZkSyncContractError.invalidParameters)
        }
        return firstly {
            tx.callPromise()
        }.map(on: web3.requestDispatcher.queue) { (result) in
            guard let data = result["0"] as? Data else {
                throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")
            }
            return data
        }
    }
    
    private func createOptions(value: BigUInt? = nil) -> TransactionOptions {
        var options = TransactionOptions()
        options.from = walletAddress
        options.to = contractAddress
        options.callOnBlock = .latest
        options.value = value
        return options
    }

    private func createReadOptions() -> TransactionOptions {
        var options = TransactionOptions()
        options.callOnBlock = .latest
        return options
    }
}

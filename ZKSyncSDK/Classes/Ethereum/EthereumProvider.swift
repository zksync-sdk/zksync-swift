//
//  EthereumProvider.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 17/01/2021.
//

import Foundation
import BigInt
import web3swift
import PromiseKit

public class EthereumProvider {
    
    static let MaxApproveAmount = BigUInt.two.power(256) - 1
    static let DefaultThreshold = BigUInt.two.power(255);
    
    let web3: web3
    let ethSigner: EthSigner
    let zkSync: ZkSync
    
    init(web3: web3, ethSigner: EthSigner, zkSync: ZkSync) {
        self.web3 = web3
        self.ethSigner = ethSigner
        self.zkSync = zkSync
        
        if let keystore = ethSigner.keystore as? EthereumKeystoreV3 {
            let keystoreManager = KeystoreManager([keystore])
            self.web3.addKeystoreManager(keystoreManager)
        } else if let keystore = ethSigner.keystore as? BIP32Keystore {
            let keystoreManager = KeystoreManager([keystore])
            self.web3.addKeystoreManager(keystoreManager)
        }
    }
    
    func approveDeposits(token: Token, limit: BigUInt?) throws -> Promise<TransactionSendingResult> {
        let erc20ContractAddress = EthereumAddress(token.address)!
        let erc20 = ERC20(web3: self.web3, provider: web3.provider, address: erc20ContractAddress)
        let amount = limit?.description ?? EthereumProvider.MaxApproveAmount.description
        let tx = try erc20.approve(from: self.ethSigner.ethereumAddress,
                                   spender: self.ethSigner.ethereumAddress,
                                   amount: amount)
        return tx.sendPromise()
    }
    
    func transfer(token: Token, amount: BigUInt, to: String) -> Promise<TransactionSendingResult> {
        
        let tx: WriteTransaction
        if token.isETH {
            tx = self.transferEth(amount: amount, to: to)
        } else {
            tx = self.transferERC20(token: token, amount: amount, to: to)
        }
        return tx.sendPromise()
    }
    
    private func transferEth(amount: BigUInt, to: String) -> WriteTransaction {
        let toAddress = EthereumAddress(to)!
        return web3.eth.sendETH(from: ethSigner.ethereumAddress,
                                to: toAddress,
                                amount: amount.description,
                                units: .wei)!
    }
    
    private func transferERC20(token: Token, amount: BigUInt, to: String) -> WriteTransaction {
        let toAddress = EthereumAddress(to)!
        let erc20ContractAddress = EthereumAddress(token.address)!
        return web3.eth.sendERC20tokensWithKnownDecimals(tokenAddress: erc20ContractAddress,
                                                         from: ethSigner.ethereumAddress,
                                                         to: toAddress,
                                                         amount: amount)!
    }
    
    public func deposit(token: Token, amount: BigUInt, userAddress: String) -> Promise<TransactionSendingResult> {
        let userAddress = EthereumAddress(userAddress)!
        if token.isETH {
            return zkSync.depositETH(address: userAddress, value: amount)
        } else {
            let tokenAddress = EthereumAddress(token.address)!
            return zkSync.depositERC20(tokenAddress: tokenAddress, amount: amount, userAddress: userAddress)
        }
    }
    
    public func fullExit(token: Token, accountId: UInt32) -> Promise<TransactionSendingResult> {
        let tokenAddress = EthereumAddress(token.address)!
        return zkSync.fullExit(tokenAddress: tokenAddress, accountId: accountId)
    }

    public func setAuthPubkeyHash(pubKeyhash: String, nonce: UInt32) -> Promise<TransactionSendingResult> {
        let data = Data(hex: pubKeyhash)
        return zkSync.setAuthPubkeyHash(pubKeyHash: data, nonce: nonce)
    }
    
    public func isDepositApproved(token: Token, threshold: BigUInt?) throws -> Bool {
        let erc20ContractAddress = EthereumAddress(token.address)!
        let erc20 = ERC20(web3: self.web3, provider: web3.provider, address: erc20ContractAddress)
        let allowance = try erc20.getAllowance(originalOwner: ethSigner.ethereumAddress, delegate: zkSync.contractAddress)
        return allowance > (threshold ?? EthereumProvider.DefaultThreshold)
    }
    
    public func getBalance() -> Promise<BigUInt> {
        web3.eth.getBalancePromise(address: ethSigner.ethereumAddress)
    }
    
    public func getNonce() -> Promise<BigUInt> {
        web3.eth.getTransactionCountPromise(address: ethSigner.ethereumAddress)
    }
    
    public func isOnChainAuthPubkeyHashSet(nonce: UInt32) -> Promise<Bool> {
        firstly {
            zkSync.authFacts(senderAddress: ethSigner.ethereumAddress, nonce: nonce)
        }.map { (data) in
            !data.isEmpty
        }
    }
}


extension TransactionOptions {
    init(amount: BigUInt, from: EthereumAddress) {
        self = TransactionOptions.defaultOptions
        self.value = amount
        self.from = from
    }
}

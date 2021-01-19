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

    let web3: web3
    let ethSigner: EthSigner
    
    init(web3: web3, ethSigner: EthSigner) {
        self.web3 = web3
        self.ethSigner = ethSigner
        
        if let keystore = ethSigner.keystore as? EthereumKeystoreV3 {
            let keystoreManager = KeystoreManager([keystore])
            self.web3.addKeystoreManager(keystoreManager)
        } else if let keystore = ethSigner.keystore as? BIP32Keystore {
            let keystoreManager = KeystoreManager([keystore])
            self.web3.addKeystoreManager(keystoreManager)
        }
    }
    
    func approveDeposits(token: Token, limit: BigUInt?) throws -> Promise<TransactionSendingResult> {
        let erc20 = ERC20(web3: self.web3, provider: web3.provider, address: self.ethSigner.ethereumAddress)
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
    
//    public CompletableFuture<TransactionReceipt> deposit(Token token, BigInteger amount, String userAddress) {
//            if (token.isETH()) {
//                return contract.depositETH(userAddress, amount).sendAsync();
//            } else {
//                return contract.depositERC20(token.getAddress(), amount, userAddress).sendAsync();
//            }
//        }
    
    private func deposit(token: Token, amount: BigUInt, userAddress: String) {
        web3.eth.deposi
    }
}


extension TransactionOptions {
    init(amount: BigUInt, from: EthereumAddress) {
        self = TransactionOptions.defaultOptions
        self.value = amount
        self.from = from
    }
}

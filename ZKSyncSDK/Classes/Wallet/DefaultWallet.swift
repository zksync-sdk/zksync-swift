//
//  DefaultWallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt
import PromiseKit
import web3swift

enum DefaultWalletError: Error {
    case internalError
}

public class DefaultWallet: Wallet {
    
    private let group = DispatchGroup()
    private let deliveryQueue = DispatchQueue(label: "com.zksyncsdk.wallet")
    
    public let provider: Provider
    internal let ethSigner: EthSigner
    internal let zkSigner: ZkSigner
    
    internal var accountId: UInt32?
    internal var pubKeyHash: String = ""
    
    public var address: String { self.ethSigner.address }
    
    public convenience init(ethSigner: EthSigner, zkSigner: ZkSigner, transport: Transport) throws {
        try self.init(ethSigner: ethSigner, zkSigner: zkSigner, provider: DefaultProvider(transport: transport))
    }

    public init(ethSigner: EthSigner, zkSigner: ZkSigner, provider: Provider) throws {
        self.provider = provider
        self.ethSigner = ethSigner
        self.zkSigner = zkSigner
        
        let accountState = try self.getAccountStateSync()
        
        self.accountId = accountState.id
        self.pubKeyHash = accountState.committed.pubKeyHash
    }
    
    public func getAccountState(completion: @escaping (Swift.Result<AccountState, Error>) -> Void) {
        self.getAccountState(queue: .main, completion: completion)
    }
    
    private func getAccountState(queue: DispatchQueue, completion: @escaping (Swift.Result<AccountState, Error>) -> Void) {
        self.provider.accountState(address: self.ethSigner.address, queue: queue, completion: completion)
    }
    
    public var isSigningKeySet: Bool {
        pubKeyHash == zkSigner.publicKeyHash
    }
    
    internal func submitSignedTransaction(_ transaction: ZkSyncTransaction,
                                          ethereumSignature: EthSignature?,
                                          fastProcessing: Bool,
                                          completion: @escaping (ZKSyncResult<String>) -> Void) {
        provider.submitTx(transaction,
                          ethereumSignature: ethereumSignature,
                          fastProcessing: fastProcessing,
                          completion: completion)
    }
    
    internal func getNonce(completion: @escaping (Swift.Result<UInt32, Error>) -> Void) {
        self.getAccountState { (result) in
            completion(Swift.Result {
                try result.get().committed.nonce
            })
        }
    }
    
    private func getAccountStateSync() throws -> AccountState {
        
        var callResult: Swift.Result<AccountState, Error>? = nil
        self.group.enter()
        self.getAccountState(queue: self.deliveryQueue) { (result) in
            callResult = result
            self.group.leave()
        }
        self.group.wait()
        
        guard let r = callResult else {
            throw DefaultWalletError.internalError
        }
        return try r.get()
    }
    
    private func getContractAddressSync() throws -> ContractAddress {
        var callResult: Swift.Result<ContractAddress, Error>? = nil
        self.group.enter()
        self.provider.contractAddress(queue: self.deliveryQueue) { (result) in
            callResult = result
            self.group.leave()
        }
        self.group.wait()
        guard let r = callResult else {
            throw DefaultWalletError.internalError
        }
        return try r.get()
    }
    
    public func createEthereumProvider(web3: web3) throws -> EthereumProvider {
        let contractAddress = try self.getContractAddressSync()
        
        guard let address = EthereumAddress(contractAddress.mainContract) else {
            throw DefaultWalletError.internalError
        }
        
        let zkSync = ZkSync(web3: web3,
                            contractAddress: address,
                            walletAddress: ethSigner.ethereumAddress)
        return EthereumProvider(web3: web3, ethSigner: ethSigner, zkSync: zkSync)
    }
}

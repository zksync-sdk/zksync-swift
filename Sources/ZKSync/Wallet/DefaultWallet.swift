//
//  DefaultWallet.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import PromiseKit
import web3swift_zksync

enum DefaultWalletError: Error {
    case internalError
    case unsupportedOperation
    case noAccountId
}

public class DefaultWallet<A: ChangePubKeyVariant, S: EthSigner>: Wallet {

    private let group = DispatchGroup()
    private let deliveryQueue = DispatchQueue(label: "com.zksync.wallet")

    public let provider: Provider
    internal let ethSigner: S
    internal let zkSigner: ZkSigner

    internal var accountId: UInt32?
    internal var pubKeyHash: String = ""

    public var address: String {
        self.ethSigner.address
    }

    public init(ethSigner: S, zkSigner: ZkSigner, provider: Provider) throws {
        self.provider = provider
        self.ethSigner = ethSigner
        self.zkSigner = zkSigner

        let accountState = try self.getAccountStateSync()

        self.accountId = accountState.id
        self.pubKeyHash = accountState.committed.pubKeyHash
    }

    public convenience init(ethSigner: S,
                            zkSigner: ZkSigner,
                            transport: Transport) throws {
        try self.init(ethSigner: ethSigner,
                      zkSigner: zkSigner,
                      provider: DefaultProvider(transport: transport))
    }

    public func getAccountState(completion: @escaping (Swift.Result<AccountState, Error>) -> Void) {
        self.getAccountState(queue: .main, completion: completion)
    }

    private func getAccountState(queue: DispatchQueue,
                                 completion: @escaping (Swift.Result<AccountState, Error>) -> Void) {
        self.provider.accountState(address: self.ethSigner.address,
                                   queue: queue,
                                   completion: completion)
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

    internal func submitSignedBatch(transactions: [ZkSyncTransaction],
                                    ethereumSignature: EthSignature,
                                    completion: @escaping (ZKSyncResult<[String]>) -> Void) {
        let pairs = transactions.map { TransactionSignaturePair(tx: $0, signature: nil) }
        self.provider.submitTxBatch(txs: pairs,
                                    ethereumSignature: ethereumSignature,
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
        var callResult: Swift.Result<AccountState, Error>?
        self.group.enter()
        self.getAccountState(queue: self.deliveryQueue) { (result) in
            callResult = result
            self.group.leave()
        }
        self.group.wait()

        guard let callResult = callResult else {
            throw DefaultWalletError.internalError
        }
        return try callResult.get()
    }

    private func getContractAddressSync() throws -> ContractAddress {
        var callResult: Swift.Result<ContractAddress, Error>?
        self.group.enter()
        self.provider.contractAddress(queue: self.deliveryQueue) { (result) in
            callResult = result
            self.group.leave()
        }
        self.group.wait()
        guard let callResult = callResult else {
            throw DefaultWalletError.internalError
        }
        return try callResult.get()
    }

    public func createEthereumProvider(web3: web3) throws -> EthereumProvider {
        let contractAddress = try self.getContractAddressSync()

        guard let address = EthereumAddress(contractAddress.mainContract) else {
            throw DefaultWalletError.internalError
        }

        let zkSync = ZkSync(web3: web3,
                            contractAddress: address,
                            walletAddress: ethSigner.ethereumAddress)
        return EthereumProvider(web3: web3,
                                keystore: ethSigner.keystore,
                                ethereumAddress: ethSigner.ethereumAddress,
                                zkSync: zkSync)
    }

    public func enable2FA(completion: @escaping (ZKSyncResult<Toggle2FAInfo>) -> Void) throws {
        guard let accountId = accountId else {
            throw DefaultWalletError.noAccountId
        }

        let timestamp = Utils.currentTimeMillis()

        let ethSignature = try ethSigner.signToggle(true, timestamp: timestamp)

        let toggle2FA = Toggle2FA(enable: true,
                                  accountId: accountId,
                                  timestamp: timestamp,
                                  signature: ethSignature)

        provider.toggle2FA(toggle2FA: toggle2FA) { result in
            completion(result)
        }
    }

    public func disable2FA(completion: @escaping (ZKSyncResult<Toggle2FAInfo>) -> Void) throws {
        guard let accountId = accountId else {
            throw DefaultWalletError.noAccountId
        }

        let timestamp = Utils.currentTimeMillis()

        let ethSignature = try ethSigner.signToggle(false, timestamp: timestamp)

        let toggle2FA = Toggle2FA(enable: false,
                                  accountId: accountId,
                                  timestamp: timestamp,
                                  signature: ethSignature)

        provider.toggle2FA(toggle2FA: toggle2FA) { result in
            completion(result)
        }
    }
}

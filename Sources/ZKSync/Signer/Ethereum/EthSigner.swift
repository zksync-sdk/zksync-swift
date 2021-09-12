//
//  EthSigner.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import web3swift_zksync
import CryptoSwift
import BigInt

public protocol EthSigner {
    
    associatedtype A: ChangePubKeyVariant
    
    var address: String { get }
    
    var ethereumAddress: EthereumAddress { get }

    var keystore: AbstractKeystore { get }
    
    func signAuth(changePubKey: ChangePubKey<A>) throws -> ChangePubKey<A>
    
    func signTransaction<T: ZkSyncTransaction>(transaction: T,
                                               nonce: UInt32,
                                               token: Token,
                                               fee: BigUInt) throws -> EthSignature?
    
    func signOrder(_ order: Order,
                   tokenSell: Token,
                   tokenBuy: Token) throws -> EthSignature
    
    func sign(message: Data) throws -> EthSignature
    
    func signBatch(transactions: [ZkSyncTransaction],
                   nonce: UInt32,
                   token: Token,
                   fee: BigUInt) throws -> EthSignature
    
    func verifySignature(_ signature: EthSignature,
                         message: Data) throws -> Bool

    func signToggle(_ enable: Bool,
                    timestamp: Int64) throws -> EthSignature
}

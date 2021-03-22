//
//  EthSigner.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import web3swift
import CryptoSwift
import BigInt

public protocol EthSigner {
    
    var address: String { get }
    
    var ethereumAddress: EthereumAddress { get }

    var keystore: AbstractKeystore { get }
    
    func signChangePubKey(pubKeyHash: String, nonce: UInt32, accountId: UInt32, changePubKeyVariant: ChangePubKeyVariant) throws -> EthSignature
    
    func signTransfer(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) throws -> EthSignature
    
    func signWithdraw(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) throws -> EthSignature
        
    func signForcedExit(to: String, nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature
    
    func sign(message: Data) throws -> EthSignature
    
    func verifySignature(_ signature: EthSignature, message: Data) throws -> Bool
}

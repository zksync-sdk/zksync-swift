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
    
    var address: String { get }
    
    var ethereumAddress: EthereumAddress { get }

    var keystore: AbstractKeystore { get }
    
    func signChangePubKey(pubKeyHash: String, nonce: UInt32, accountId: UInt32, changePubKeyVariant: ChangePubKeyVariant) throws -> EthSignature
    
    func signTransfer(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: TokenId, fee: BigUInt) throws -> EthSignature
    
    func signWithdraw(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) throws -> EthSignature
        
    func signForcedExit(to: String, nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature
    
    func signMintNFT(contentHash: String, recepient: String, nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature

    func signWithdrawNFT(to: String, tokenId: UInt32, nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature
    
    func signSwap(nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature
    
    func signOrder(_ order: Order, tokenSell: Token, tokenBuy: Token) throws -> EthSignature
    
    func sign(message: Data) throws -> EthSignature

    func signBatch(transactions: [ZkSyncTransaction], nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature

    func verifySignature(_ signature: EthSignature, message: Data) throws -> Bool
    
    func signToggle(_ enable: Bool, timestamp: TimeInterval) throws -> EthSignature
}

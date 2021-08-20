//
//  DefaultEthSigner.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 22/01/2021.
//

import Foundation

import web3swift_zksync
import CryptoSwift
import BigInt

public class DefaultEthSigner: EthSigner {
    
    public let keystore: AbstractKeystore
    
    public init(privateKey: String) throws {
        let privatKeyData = Data(hex: privateKey)
        guard let keystore = try EthereumKeystoreV3(privateKey: privatKeyData) else {
            throw EthSignerError.invalidKey
        }
        self.keystore = keystore
    }
    
    public init(mnemonic: String) throws {
        guard let keystore = try BIP32Keystore(mnemonics: mnemonic) else {
            throw EthSignerError.invalidMnemonic
        }
        self.keystore = keystore
    }
    
    public var address: String {
        return ethereumAddress.address.lowercased()
    }
    
    public var ethereumAddress: EthereumAddress {
        return keystore.addresses!.first!
    }
    
    public func signChangePubKey(pubKeyHash: String, nonce: UInt32, accountId: UInt32, changePubKeyVariant: ChangePubKeyVariant) throws -> EthSignature {
        return try self.sign(message: self.createChangePubKeyMessage(pubKeyHash: pubKeyHash, nonce: nonce, accountId: accountId, changePubKeyVariant: changePubKeyVariant))
    }
    
    public func signTransfer(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: TokenId, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createFullTransferMessage(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee))
    }
    
    public func signWithdraw(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createFullWithdrawMessage(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee))
    }
    
    public func signForcedExit(to: String, nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createFullForcedExitMessage(to: to, nonce: nonce, token: token, fee: fee))
    }
    
    public func signMintNFT(contentHash: String, recepient: String, nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createFullMintNFTMessage(contentHash: contentHash, recepient: recepient, nonce: nonce, token: token, fee: fee))
    }
    
    public func signWithdrawNFT(to: String, tokenId: UInt32, nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createFullWithdrawNFTMessage(to: to, tokenId: tokenId, nonce: nonce, token: token, fee: fee))
    }
    
    public func signSwap(nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createFullSwapMessage(nonce: nonce, token: token, fee: fee))
    }
    
    public func signOrder(_ order: Order, tokenSell: Token, tokenBuy: Token) throws -> EthSignature {
        let message = self.createFullOrderMessage(recepient: order.recepientAddress,
                                                  amount: order.amount,
                                                  tokenSell: tokenSell,
                                                  tokenBuy: tokenBuy,
                                                  ratio: order.ratio,
                                                  nonce: order.nonce)
        return try self.sign(message: message)
    }
    
    public func signBatch(transactions: [ZkSyncTransaction], nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature {
        
        let message =
            try transactions.map { (tx) -> String in
                switch tx {
                case let forcedExitTx as ForcedExit:
                    return self.createForcedExitMessagePart(to: forcedExitTx.target, token: token, fee: fee)
                case let mintNFTTx as MintNFT:
                    return self.createMintNFTMessagePart(contentHash: mintNFTTx.contentHash, recepient: mintNFTTx.recipient, token: token, fee: fee)
                case let transferTx as Transfer:
                    let tokenId = transferTx.tokenId ?? token
                    return self.createTransferMessagePart(to: transferTx.to, accountId: transferTx.accountId, amount: transferTx.amount, token: tokenId, fee: BigUInt(stringLiteral: transferTx.fee))
                case let withdrawTx as Withdraw:
                    return self.createWithdrawMessagePart(to: withdrawTx.to, accountId: withdrawTx.accountId, amount: withdrawTx.amount, token: token, fee: fee)
                case let withdrawNFTTx as WithdrawNFT:
                    return self.createWithdrawNFTMessagePart(to: withdrawNFTTx.to, tokenId: withdrawNFTTx.token, token: token, fee: fee)
                case is Swap:
                    return self.createSwapMessagePart(token: token, fee: fee)
                default:
                    throw EthSignerError.invalidTransactionType("Transaction type \(tx.type) is not supported by batch")
                }
            }
            .joined(separator: "\n")
            .attaching(nonce: nonce)
            .data(using: .utf8)!
        
        return try self.sign(message: message)
    }
    
    
    public func sign(message: Data) throws -> EthSignature {
        
        var signatureData: Data? = nil
        
        if keystore is EthereumKeystoreV3 {
            signatureData = try Web3Signer.signPersonalMessage(message,
                                                               keystore: keystore as! EthereumKeystoreV3,
                                                               account: ethereumAddress,
                                                               password: "web3swift")
        } else if keystore is BIP32Keystore {
            signatureData = try Web3Signer.signPersonalMessage(message,
                                                               keystore: keystore as! BIP32Keystore,
                                                               account: ethereumAddress,
                                                               password: "web3swift")
        }
        
        guard let validSignatureData = signatureData else {
            throw EthSignerError.signingFailed
        }
        
        return EthSignature(signature: validSignatureData.toHexString().addHexPrefix(),
                            type: .ethereumSignature)
    }
    
    public func verifySignature(_ signature: EthSignature, message: Data) throws -> Bool {
        let signatureData = Data(hex: signature.signature)
        guard let hash = Web3Utils.hashPersonalMessage(message) else {
            throw EthSignerError.invalidMessage
        }
        
        let publicKeyData = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData)
        
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: "web3swift", account: self.ethereumAddress)
        defer { Data.zero(&privateKey) }
        
        let keystorePublicKeyData = Web3Utils.privateToPublic(privateKey)
        
        return publicKeyData == keystorePublicKeyData
    }
}

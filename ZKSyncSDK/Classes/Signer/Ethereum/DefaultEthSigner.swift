//
//  DefaultEthSigner.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 22/01/2021.
//

import Foundation

import web3swift
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
    
    public func signTransfer(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createTransferMessage(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee))
    }
    
    public func signWithdraw(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createWithdrawMessage(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee))
    }
    
    public func signForcedExit(to: String, nonce: UInt32, token: Token, fee: BigUInt) throws -> EthSignature {
        return try self.sign(message: self.createForcedExitMessage(to: to, nonce: nonce, token: token, fee: fee))
    }
    
    public func sign(message: Data) throws -> EthSignature {
        
        guard let signatureData =
                try Web3Signer.signPersonalMessage(message,
                                                   keystore: self.keystore,
                                                   account: self.ethereumAddress,
                                                   password: "web3swift") else {
            throw EthSignerError.signingFailed
        }
        
        return EthSignature(signature: signatureData.toHexString().addHexPrefix(),
                            type: .ethereumSignature)
    }
    
    public func verifySignature(_ signature: EthSignature, message: Data) throws -> Bool {
        let signatureData = Data(hex: signature.signature)
        guard let hash = Web3Utils.hashPersonalMessage(message) else {
            throw EthSignerError.invalidMessage
        }
        
        let publicKeyData = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData)
        
        var privateKey = try self.keystore.UNSAFE_getPrivateKeyData(password: "web3swift", account: self.ethereumAddress)
        defer { Data.zero(&privateKey) }
        
        let keystorePublicKeyData = Web3Utils.privateToPublic(privateKey)
        
        return publicKeyData == keystorePublicKeyData
    }
}

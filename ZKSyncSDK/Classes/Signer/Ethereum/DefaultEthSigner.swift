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
    
    private let keystore: AbstractKeystore
    
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
        return ethereumAddress.address
    }
    
    private var ethereumAddress: EthereumAddress {
        return keystore.addresses!.first!
    }
    
    public func signChangePubKey(pubKeyHash: String, nonce: Int32, accountId: Int32) throws -> EthSignature {
        return try self.sign(message: self.createChangePubKeyMessage(pubKeyHash: pubKeyHash, nonce: nonce, accountId: accountId))
    }
    
    public func signTransfer(to: String, accountId: Int32, nonce: Int32, amount: BigUInt, token: Token, fee: BigUInt) throws -> EthSignature{
        return try self.sign(message: self.createTransferMessage(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee))
    }
    
    public func signWithdraw(to: String, accountId: Int32, nonce: Int32, amount: BigUInt, token: Token, fee: BigUInt) throws -> EthSignature{
        return try self.sign(message: self.createWithdrawMessage(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee))
    }
    
    public func sign(message: String) throws -> EthSignature {
        
        guard let data = message.data(using: .utf8) else {
            throw EthSignerError.invalidMessage
        }
        
        guard let signatureData =
                try Web3Signer.signPersonalMessage(data,
                                                   keystore: self.keystore,
                                                   account: self.ethereumAddress,
                                                   password: "web3swift") else {
            throw EthSignerError.signingFailed
        }
        
        return EthSignature(signature: signatureData.toHexString().addHexPrefix(),
                            type: .ethereumSignature)
    }
    
    public func verifySignature(_ signature: EthSignature, message: String) throws -> Bool {
        let signatureData = Data(hex: signature.signature)
        guard let messageData = message.data(using: .utf8),
              let hash = Web3Utils.hashPersonalMessage(messageData) else {
            throw EthSignerError.invalidMessage
        }
        
        let publicKeyData = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData)
        
        var privateKey = try self.keystore.UNSAFE_getPrivateKeyData(password: "web3swift", account: self.ethereumAddress)
        defer { Data.zero(&privateKey) }
        
        let keystorePublicKeyData = Web3Utils.privateToPublic(privateKey)
        
        return publicKeyData == keystorePublicKeyData
    }
}

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

public class EthSigner {
    
    private let keystore: EthereumKeystoreV3
    
    public init(privateKey: String) throws {
        let privatKeyData = Data(hex: privateKey)
        guard let keystore = try EthereumKeystoreV3(privateKey: privatKeyData) else {
            throw EthSignerError.invalidKey
        }
        self.keystore = keystore
    }
    
    public var address: String {
        return keystore.getAddress()!.address
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
                                                   account: self.keystore.getAddress()!,
                                                   password: "web3swift") else {
            throw EthSignerError.signingFailed
        }
        
        return EthSignature(signature: signatureData.toHexString().addHexPrefix(),
                            type: .ethereumSignature)
    }
}

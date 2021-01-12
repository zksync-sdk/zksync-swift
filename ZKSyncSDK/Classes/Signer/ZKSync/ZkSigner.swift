//
//  ZkSigner.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation
import CryptoSwift

enum ZkSignerError: Error {
    case invalidPrivateKey
    case incorrectDataLength
    case invalidSignatureType(EthSignature.SignatureType)
}

public class ZkSigner {
    
    private static let Message = "Access zkSync account.\n\nOnly sign this message for a trusted client!"
    
    let privateKey: ZKPrivateKey
    let publicKey: ZKPackedPublicKey
    let publicKeyHash: ZKPublicHash
    
    public init(privateKey: ZKPrivateKey) throws {
        self.privateKey = privateKey
        
        switch ZKCryptoSDK.getPublicKey(privateKey: privateKey) {
        case .success(let key):
            self.publicKey = key
        default:
            throw ZkSignerError.invalidPrivateKey
        }
        
        switch ZKCryptoSDK.getPublicKeyHash(publicKey: self.publicKey) {
        case .success(let hash):
            self.publicKeyHash = hash
        default:
            throw ZkSignerError.invalidPrivateKey
        }
    }
    
    public convenience init(seed: Data) throws {
        switch ZKCryptoSDK.generatePrivateKey(seed: seed) {
        case .success(let privateKey):
            try self.init(privateKey: privateKey)
        case .error(let error):
            throw error
        }
    }
    
    public convenience init(rawPrivateKey: Data) throws {
        if rawPrivateKey.count != ZKPrivateKey.bytesLength {
            throw ZkSignerError.incorrectDataLength
        }
        try self.init(privateKey: ZKPrivateKey(rawPrivateKey))
    }
    
    public convenience init(ethSigner: EthSigner, chainId: ChainId) throws {
        var message = ZkSigner.Message
        if chainId != .mainnet {
            message = "\(message)\nChain ID: \(chainId.id)."
        }
        let signature = try ethSigner.sign(message: message)
        
        if signature.type != .ethereumSignature {
            throw ZkSignerError.invalidSignatureType(signature.type)
        }
        
        try self.init(seed: Data(hex: signature.signature))
    }
    
    public func sign(message: Data) throws -> Signature {
        switch ZKCryptoSDK.signMessage(privateKey: self.privateKey, message: message) {
        case .success(let signature):
            return Signature(pubKey: publicKey.hexEncodedString(),
                             signature: signature.hexEncodedString())
        case .error(let error):
            throw error
        }
    }
    
    public func sign(changePubKey: ChangePubKey) throws -> ChangePubKey {
        var mutableChangePubKey = changePubKey
        var data = Data()
        
        data.append(contentsOf: [0x07])
        data.append(try Utils.accountIdToBytes(changePubKey.accountId))
        data.append(try Utils.addressToBytes(changePubKey.account))
        data.append(try Utils.addressToBytes(changePubKey.newPkHash))
        data.append(try Utils.tokenIdToBytes(changePubKey.feeToken))
        data.append(try Utils.feeToBytes(changePubKey.feeInteger))
        data.append(try Utils.nonceToBytes(changePubKey.nonce))
        
        let signature = try self.sign(message: data)
        mutableChangePubKey.signature = signature
        return mutableChangePubKey
    }
}

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

public enum EthSignerError: Error {
    case invalidKey
    case invalidMessage
    case signingFailed
}

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
    
    public func signChangePubKey(pubKeyHash: String, nonce: Int, accountId: Int) throws -> EthSignature {
        return try self.sign(message: self.createChangePubKeyMessage(pubKeyHash: pubKeyHash, nonce: nonce, accountId: accountId))
    }
    
    public func signTransfer(to: String, accountId: Int, nonce: Int, amount: Decimal, token: Token, fee: Decimal) throws -> EthSignature{
        return try self.sign(message: self.createTransferMessage(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee))
    }
    
    public func signWithdraw(to: String, accountId: Int, nonce: Int, amount: Decimal, token: Token, fee: Decimal) throws -> EthSignature{
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
        
        return EthSignature(signature: signatureData.toHexString(),
                            type: .ethereumSignature)
    }
}

public extension EthSigner {
    func createChangePubKeyMessage(pubKeyHash: String, nonce: Int, accountId: Int) -> String {
        
        let pubKeyHashStripped = pubKeyHash.deletingPrefix("sync:").lowercased()
        
        return """
        Register zkSync pubkey:

        \(pubKeyHashStripped)
        nonce:\(nonce.bytes().toHexString())
        account id: \(accountId.bytes().toHexString())

        Only sign this message for a trusted client!
        """
    }
    
    func createTransferMessage(to: String, accountId: Int, nonce: Int, amount: Decimal, token: Token, fee: Decimal) -> String{
        return """
        Transfer \(amount) \(token.symbol)
        To: \(to.lowercased())
        Nonce: \(nonce)
        Fee: \(fee) \(token.symbol)
        Account Id: \(accountId)
        """
    }

    func createWithdrawMessage(to: String, accountId: Int, nonce: Int, amount: Decimal, token: Token, fee: Decimal) -> String{
        return """
        Withdraw \(amount) \(token.symbol)
        To: \(to.lowercased())
        Nonce: \(nonce)
        Fee: \(fee) \(token.symbol)
        Account Id: \(accountId)
        """
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension Int {
    func bytes() -> Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}

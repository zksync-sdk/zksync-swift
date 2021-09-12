//
//  Create2EthSigner.swift
//  ZKSync
//
//  Created by Maxim Makhun on 9/3/21.
//

import Foundation

import web3swift_zksync
import BigInt
import CryptoSwift

public class Create2EthSigner: EthSigner {
    
    public typealias A = ChangePubKeyCREATE2
    
    let authData: A
    
    public var address: String
    
    public var ethereumAddress: EthereumAddress {
        preconditionFailure("Not supported.")
    }
    
    public var keystore: AbstractKeystore {
        preconditionFailure("Not supported.")
    }

    init(zkSigner: ZkSigner, create2Data: A) throws {
        self.address = ""
        self.authData = create2Data
        
        let saltArg = create2Data.saltArg
        
        let salt = try generateSalt(saltArg: saltArg,
                                    pubKeyHash: zkSigner.publicKeyHash)
        self.address = try generateAddress(creatorAddress: create2Data.creatorAddress,
                                           salt: salt,
                                           codeHash: Data(hex: create2Data.codeHash))
    }
    
    public func signAuth(changePubKey: ChangePubKey<ChangePubKeyCREATE2>) throws -> ChangePubKey<ChangePubKeyCREATE2> {
        changePubKey.ethAuthData = authData
        return changePubKey
    }
    
    func generateSalt(saltArg: String, pubKeyHash: String) throws -> Data {
        var data = Data()
        data.append(Data(hex: saltArg))
        data.append(try Utils.addressToBytes(pubKeyHash))
        
        let hash = data.sha3(.keccak256)
        
        return hash
    }
    
    func generateAddress(creatorAddress: String, salt: Data, codeHash: Data) throws -> String {
        var data = Data()
        data.append(Data([0xff]))
        data.append(Data(hex: creatorAddress))
        data.append(salt)
        data.append(codeHash)

        let hash = data.sha3(.keccak256)

        let hashSubdata = hash.subdata(in: 12..<hash.count).toHexString().addHexPrefix()

        return hashSubdata
    }
    
    public func signTransaction<T>(transaction: T,
                                   nonce: UInt32,
                                   token: Token,
                                   fee: BigUInt) throws -> EthSignature? where T : ZkSyncTransaction {
        return nil
    }
    
    public func signOrder(_ order: Order,
                          tokenSell: Token,
                          tokenBuy: Token) throws -> EthSignature {
        throw EthSignerError.unsupportedOperation
    }
    
    public func sign(message: Data) throws -> EthSignature {
        throw EthSignerError.unsupportedOperation
    }
    
    public func signBatch(transactions: [ZkSyncTransaction],
                          nonce: UInt32,
                          token: Token,
                          fee: BigUInt) throws -> EthSignature {
        throw EthSignerError.unsupportedOperation
    }
    
    public func verifySignature(_ signature: EthSignature,
                                message: Data) throws -> Bool {
        throw EthSignerError.unsupportedOperation
    }
    
    public func signToggle(_ enable: Bool,
                           timestamp: Int64) throws -> EthSignature {
        throw EthSignerError.unsupportedOperation
    }
}

//
//  EthSigner.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import web3swift
import CryptoSwift

public enum EthSignerError: Error {
    case invalidKey
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
        return keystore.addresses![0].address
    }
}

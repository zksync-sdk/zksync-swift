//
//  ChangePubKeyECDSA.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/03/2021.
//

import Foundation

public struct ChangePubKeyECDSA: ChangePubKeyVariant {
    
    public let type: ChangePubKeyAuthType = .ECDSA
    
    public var ethSignature: String?
    public var batchHash: String

    public var bytes: Data {
        return Data(hex: batchHash)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case ethSignature
        case batchHash
    }
}

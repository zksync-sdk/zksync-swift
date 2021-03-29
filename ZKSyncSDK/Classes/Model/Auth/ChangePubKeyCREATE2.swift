//
//  ChangePubKeyCREATE2.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/03/2021.
//

import Foundation

public struct ChangePubKeyCREATE2: ChangePubKeyVariant {
    
    public let type: ChangePubKeyAuthType = .CREATE2;

    public var creatorAddress: String
    public var saltArg: String
    public var codeHash: String

    public let bytes = Data(repeating: 0, count: 32)
    
    enum CodingKeys: String, CodingKey {
        case type
        case creatorAddress
        case saltArg
        case codeHash
    }
}

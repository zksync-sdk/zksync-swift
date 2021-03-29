//
//  ChangePubKeyOnchain.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/03/2021.
//

import Foundation

public struct ChangePubKeyOnchain: ChangePubKeyVariant {
    public let type: ChangePubKeyAuthType = .onchain
    public let bytes: Data = Data(repeating: 0, count: 32)
    
    enum CodingKeys: String, CodingKey {
        case type
    }
}

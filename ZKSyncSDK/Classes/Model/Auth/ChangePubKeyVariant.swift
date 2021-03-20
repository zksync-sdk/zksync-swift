//
//  ChangePubKeyVariant.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/03/2021.
//

import Foundation

public enum ChangePubKeyAuthType {
    case onchain
    case ECDSA
    case CREATE2
}

public protocol ChangePubKeyVariant {
    var type: ChangePubKeyAuthType { get }
    var bytes: Data { get }
}

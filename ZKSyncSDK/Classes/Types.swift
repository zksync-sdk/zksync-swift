//
//  Types.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

public typealias ZKSyncResult<T> = Result<T, Error>

enum VerificationMethod {
    case ECDSA, ERC1271
}

struct EthSignerType {
    var verificationMethod: VerificationMethod
    var signedMsgPrefixed: Bool
}

enum TxEhSignature {
    case Ethereum(signature: String)
    case EIP1271(signature: String)
}

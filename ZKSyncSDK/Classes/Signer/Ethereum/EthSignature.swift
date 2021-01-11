//
//  EthSignature.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 09/01/2021.
//

import Foundation

public struct EthSignature {
    public enum SignatureType {
        case ethereumSignature
        case EIP1271Signature
    }
    
    let signature: String
    let type: SignatureType
}

//
//  EthSignature.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 09/01/2021.
//

import Foundation

public struct EthSignature: Encodable {
    public enum SignatureType: String, Encodable {
        case ethereumSignature = "EthereumSignature"
        case EIP1271Signature
    }
    
    let signature: String
    let type: SignatureType
}

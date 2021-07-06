//
//  Signature.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation

public struct Signature: Encodable {
    let pubKey: String
    let signature: String
}

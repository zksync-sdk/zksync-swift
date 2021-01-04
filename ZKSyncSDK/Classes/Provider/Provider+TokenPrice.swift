//
//  Provider+TokenPrice.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

public struct Token {
    var id: Int
    var address: String
    var symbol: String
    var decimals: Int
}

extension Provider {
    public func tokenPrice(token: Token, completion: @escaping (ZKSyncResult<BigInt>) -> Void) {
        transport.request(method: "get_token_price", params: [token.symbol], completion: completion)
    }
}

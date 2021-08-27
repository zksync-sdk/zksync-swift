//
//  Provider+TokenPrice.swift
//  ZKSync
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

extension DefaultProvider {
    public func tokenPrice(token: Token, completion: @escaping (ZKSyncResult<Decimal>) -> Void) {
        transport.send(method: "get_token_price", params: [token.symbol]) { (result: ZKSyncResult<String>) in
            completion(result.map { Decimal(string: $0)! } )
        }
    }
}

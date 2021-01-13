//
//  DefaultProvider+Tokens.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

extension DefaultProvider {
    public func tokens(completion: @escaping (ZKSyncResult<Tokens>) -> Void) {
        self.transport.send(method: "tokens", params: [String](), completion: completion)
    }
}

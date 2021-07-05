//
//  DefaultProvider+Tokens.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

extension DefaultProvider {
    public func tokens(completion: @escaping (ZKSyncResult<Tokens>) -> Void) {
        if let tokens = self.tokensCache {
            completion(.success(tokens))
        } else {
            self.transport.send(method: "tokens", params: [String]()) { (result: TransportResult<Tokens>) in
                self.tokensCache = try? result.get()
                completion(result)
            }
        }
    }
}

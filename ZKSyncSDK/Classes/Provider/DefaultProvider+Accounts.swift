//
//  Provider+Accounts.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

extension DefaultProvider {
    public func accountState(address: String, completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        self.transport.send(method: "account_info", params: [address], completion: completion)
    }
}

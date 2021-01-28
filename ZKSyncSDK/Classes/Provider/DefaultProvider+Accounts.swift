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
        self.accountState(address: address, queue: .main, completion: completion)
    }
    
    public func accountState(address: String,
                      queue: DispatchQueue,
                      completion: @escaping (ZKSyncResult<AccountState>) -> Void) {
        self.transport.send(method: "account_info", params: [address], queue: queue, completion: completion)
    }

}

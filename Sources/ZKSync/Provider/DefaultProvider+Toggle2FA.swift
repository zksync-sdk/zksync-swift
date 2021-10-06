//
//  DefaultProvider+Toggle2FA.swift
//  ZKSync
//
//  Created by Maxim Makhun on 8/25/21.
//

import Foundation

extension DefaultProvider {

    public func toggle2FA(toggle2FA: Toggle2FA,
                          completion: @escaping (ZKSyncResult<Toggle2FAInfo>) -> Void) {
         self.transport.send(method: "toggle_2fa",
                             params: [toggle2FA],
                             completion: completion)
    }
}

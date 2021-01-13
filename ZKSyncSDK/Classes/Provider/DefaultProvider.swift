//
//  DefaultProvider.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

public class DefaultProvider: Provider {
    let transport: Transport
    
    public init(transport: Transport) {
        self.transport = transport
    }
}

//
//  Provider.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

public class Provider {
    let transport: Transport
    
    public init(transport: Transport) {
        self.transport = transport
    } 
}


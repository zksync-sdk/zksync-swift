//
//  Provider.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

public class Provider {
    let transport: JRPCTransport
    
    public init(network: Network) {
        self.transport = JRPCTransport(network: network)
    } 
}


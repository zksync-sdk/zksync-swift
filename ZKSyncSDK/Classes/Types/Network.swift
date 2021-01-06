//
//  Network.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

public enum Network {
    case localhost, rinkeby, ropsten, mainnet
    
    var address: String {
        switch self {
        case .localhost:
            return "http://127.0.0.1:3030"
        case .rinkeby:
            return "https://rinkeby-api.zksync.io/jsrpc"
        case .ropsten:
            return "https://ropsten-api.zksync.io/jsrpc"
        case .mainnet:
            return "https://api.zksync.io/jsrpc"
        }
    }
    
    var url: URL {
        return URL(string: self.address)!
    }
}

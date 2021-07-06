//
//  DefaultProvider.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

public class DefaultProvider: Provider {
    
    let transport: Transport
    
    internal var tokensCache: Tokens?
    
    public init(transport: Transport) {
        self.transport = transport
    }
    
    public convenience init(chainId: ChainId) {
        switch chainId {
        case .mainnet:
            self.init(transport: HTTPTransport(networkURL: URL(string: "https://api.zksync.io/jsrpc")!))
        case .localhost:
            self.init(transport: HTTPTransport(networkURL: URL(string: "http://127.0.0.1:3030")!))
        case .rinkeby:
            self.init(transport: HTTPTransport(networkURL: URL(string: "https://rinkeby-api.zksync.io/jsrpc")!))
        case .ropsten:
            self.init(transport: HTTPTransport(networkURL: URL(string: "https://ropsten-api.zksync.io/jsrpc")!))
        }
    }
    
    public static func betaProvider(chainId: ChainId) -> Provider {
        switch chainId {
        case .rinkeby:
            return DefaultProvider(transport: HTTPTransport(networkURL: URL(string: "https://rinkeby-beta-api.zksync.io/jsrpc")!))
        case .ropsten:
            return DefaultProvider(transport: HTTPTransport(networkURL: URL(string: "https://ropsten-beta-api.zksync.io/jsrpc")!))
        default:
            fatalError("Unsupported beta network for given chain id")
        }
    }
}

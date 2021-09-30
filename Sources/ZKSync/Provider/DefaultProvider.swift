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
            let url = URL(string: "https://api.zksync.io/jsrpc")!
            self.init(transport: HTTPTransport(networkURL: url))
        case .localhost:
            let url = URL(string: "http://127.0.0.1:3030")!
            self.init(transport: HTTPTransport(networkURL: url))
        case .rinkeby:
            let url = URL(string: "https://rinkeby-api.zksync.io/jsrpc")!
            self.init(transport: HTTPTransport(networkURL: url))
        case .ropsten:
            let url = URL(string: "https://ropsten-api.zksync.io/jsrpc")!
            self.init(transport: HTTPTransport(networkURL: url))
        }
    }

    public static func betaProvider(chainId: ChainId) -> Provider {
        switch chainId {
        case .rinkeby:
            let url = URL(string: "https://rinkeby-beta-api.zksync.io/jsrpc")!
            return DefaultProvider(transport: HTTPTransport(networkURL: url))
        case .ropsten:
            let url = URL(string: "https://ropsten-beta-api.zksync.io/jsrpc")!
            return DefaultProvider(transport: HTTPTransport(networkURL: url))
        default:
            fatalError("Unsupported beta network for given chain id")
        }
    }
}

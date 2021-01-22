//
//  DefaultProvider.swift
//  ZKSyncSDK
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
            self.init(transport: HTTPTransport(network: .mainnet))
        case .localhost:
            self.init(transport: HTTPTransport(network: .localhost))
        case .rinkeby:
            self.init(transport: HTTPTransport(network: .rinkeby))
        case .ropsten:
            self.init(transport: HTTPTransport(network: .ropsten))
        }
    }
}

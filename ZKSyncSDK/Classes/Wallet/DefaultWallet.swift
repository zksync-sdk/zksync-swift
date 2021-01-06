//
//  DefaultWallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation

public class DefaultWallet: Wallet {
    
    private let provider: Provider
    
    public init(transport: Transport) {
        self.provider = Provider(transport: transport)
    }
    
    public func getContractAddress(completion: @escaping (Result<ContractAddress, Error>) -> Void) {
        self.provider.contractAddress(completion: completion)
    }
}

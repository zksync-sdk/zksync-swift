//
//  DefaultWallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation

public class DefaultWallet: Wallet {
    
    private let provider: Provider
    private let ethSigner: EthSigner
    
    public init(ethSigner: EthSigner, transport: Transport) {
        self.provider = Provider(transport: transport)
        self.ethSigner = ethSigner
    }
    
    public func getContractAddress(completion: @escaping (Result<ContractAddress, Error>) -> Void) {
        self.provider.contractAddress(completion: completion)
    }
    
    public func getAccountInfo(completion: @escaping (Result<AccountState, Error>) -> Void) {
        self.provider.accountInfo(address: self.ethSigner.address, completion: completion)
    }

}

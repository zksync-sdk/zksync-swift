//
//  DefaultWallet.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation
import BigInt

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
    
    public func getTokenPrice(completion: @escaping (Result<Decimal, Error>) -> Void) {
        self.provider.tokenPrice(token: Token.ETH, completion: completion)
    }

}

//
//  TransactionFeeRequest+Encoding.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

extension TransactionFeeRequest: Encodable {

    public func encode(to encoder: Encoder) throws {
        switch transactionType {
        case .changePubKey, .changePubKeyOnchainAuth:
            try self.encodeChangePubKey(to: encoder)
        default:
            try self.encodePlain(to: encoder)
        }
    }
    
    private func encodePlain(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(transactionType.feeIdentifier)
        try container.encode(address)
        try container.encode(tokenIdentifier)
    }
    
    private struct ChangePubKeyIdentifier: Encodable {
        let changePubKey: [String : Bool]
        
        enum CodingKeys: String, CodingKey {
            case changePubKey = "ChangePubKey"
        }
    }
    
    private func encodeChangePubKey(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        let value = transactionType == .changePubKeyOnchainAuth
        let identifier = ChangePubKeyIdentifier(changePubKey: ["onchainPubkeyAuth": value])
        try container.encode(identifier)
        try container.encode(address)
        try container.encode(tokenIdentifier)
    }
}

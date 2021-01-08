//
//  TransactionType+Encoding.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 08/01/2021.
//

import Foundation

extension TransactionType {
    var feeIdentifier: String {
        switch self {
        case .withdraw, .forcedExit:
            return "Withdraw"
        case .transfer:
            return "Transfer"
        case .fastWithdraw:
            return "FastWithdraw"
        case .changePubKey, .changePubKeyOnchainAuth:
            return  "ChangePubKey"
        }
    }
}

extension TransactionType: Encodable {
    
    private struct ChangePubKeyIdentifier: Encodable {
        let changePubKey: [String : Bool]
        enum CodingKeys: String, CodingKey {
            case changePubKey = "ChangePubKey"
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .changePubKey, .changePubKeyOnchainAuth:
            let value = self == .changePubKeyOnchainAuth
            let identifier = ChangePubKeyIdentifier(changePubKey: ["onchainPubkeyAuth": value])
            try container.encode(identifier)
        default:
            try container.encode(feeIdentifier)
        }
    }
}

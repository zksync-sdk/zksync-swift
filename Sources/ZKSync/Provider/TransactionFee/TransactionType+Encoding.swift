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
        case .legacyChangePubKey, .legacyChangePubKeyOnchainAuth:
            return  "ChangePubKey"
        case .changePubKeyOnchain:
            return "Onchain"
        case .changePubKeyECDSA:
            return "ECDSA"
        case .changePubKeyCREATE2:
            return "CREATE2"
        case .swap:
            return "Swap"
        case .mintNFT:
            return "MintNFT"
        case .withdrawNFT:
            return "WithdrawNFT"
        case .fastWithdrawNFT:
            return "FastWithdrawNFT"
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
        case .legacyChangePubKey, .legacyChangePubKeyOnchainAuth:
            let value = self == .legacyChangePubKeyOnchainAuth
            let identifier = ChangePubKeyIdentifier(changePubKey: ["onchainPubkeyAuth": value])
            try container.encode(identifier)
        case .changePubKeyOnchain, .changePubKeyECDSA, .changePubKeyCREATE2:
            try container.encode(["ChangePubKey" : feeIdentifier])
        default:
            try container.encode(feeIdentifier)
        }
    }
}

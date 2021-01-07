//
//  Provider+TransactionFee.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

public enum TransactionType: String, Codable {
    case withdraw
    case transfer
    case fastWithdraw
    case changePubKey
    case changePubKeyOnchainAuth
    case forcedExit
    
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

//struct ChangePubKeyRequestParameters: Encodable {
//    let transactionType: TransactionType
//    let address
//}
//
public struct TransactionFeeRequest: Encodable {
    var transactionType: TransactionType
    var address: String
    var tokenIdentifier: String
    
    public func encode(to encoder: Encoder) throws {
        switch transactionType {
        case .changePubKey, .changePubKeyOnchainAuth:
            try self.encodeChangePubKey(to: encoder)
        default:
            try self.encode(to: encoder)
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

public struct TransactionFeeDetails: Codable {
    var gasTxAmount: String
    var gasPriceWei: String
    var gasFee: String
    var zkpFee: String
    var totalFee: String
}

extension Provider {
    public func transactionFee(request: TransactionFeeRequest, completion: @escaping (ZKSyncResult<TransactionFeeDetails>) -> Void) {
        
//        let oa = ["onchainPubkeyAuth" : false]
//        let a = ["ChangePubKey" : oa]
//        
//        let params = [a, request.address, request.tokenIdentifier]
        self.transport.send(method: "get_tx_fee", params: request, completion: completion)
    }
}

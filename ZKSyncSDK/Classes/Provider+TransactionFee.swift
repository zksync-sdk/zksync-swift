//
//  Provider+TransactionFee.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

public enum TransactionType: String, Codable {
    case withdraw = "Withdraw"
    case transfer = "Transfer"
    case fastWithdraw = "FastWithdraw"
    case changePubKey = "ChangePubKey"
}

public struct TransactionFeeRequest: Codable {
    var transactionType: TransactionType
    var address: String
    var tokenIdentifier: String
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
        self.transport.request(method: "get_tx_fee", params: request, completion: completion)
    }
}

//
//  TransactionStatus.swift
//  ZKSync
//
//  Created by Maxim Makhun on 7/14/21.
//

import Foundation

/// Enum, which is used by `PollingTransactionReceiptProcessor` to verify in what transaction status
/// it should be waiting for.
public enum TransactionStatus {
    case sent
    case commited
    case verified
}

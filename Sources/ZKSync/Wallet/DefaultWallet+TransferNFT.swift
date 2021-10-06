//
//  DefaultWallet+TransferNFT.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/05/2021.
//

//import Foundation
//import BigInt
//import PromiseKit
//
//extension DefaultWallet {
//
//    // swiftlint:disable:next function_parameter_count
//    public func transferNFT(to: String,
//                            token: NFT,
//                            fee: TransactionFee,
//                            nonce: UInt32?,
//                            timeRange: TimeRange,
//                            completion: @escaping (Swift.Result<[String], Error>) -> Void) {
//
//        firstly {
//            return self.getNonceAccountIdPair(for: nonce)
//        }.then { (nonce, accountId) in
//            return self.getTokens().map { return ($0, nonce, accountId) }
//        }.then { (tokens, nonce, accountId) -> Promise<[String]> in
//
//            let feeToken = try tokens.tokenByTokenIdentifier(fee.feeToken)
//
//            let transferNFT = Transfer(accountId: accountId,
//                                       from: self.ethSigner.address,
//                                       to: to,
//                                       token: token.id,
//                                       amount: .one,
//                                       fee: BigUInt.zero.description,
//                                       nonce: nonce,
//                                       tokenId: token,
//                                       timeRange: timeRange)
//
//            let transferFee = Transfer(accountId: accountId,
//                                       from: self.ethSigner.address,
//                                       to: self.ethSigner.address,
//                                       token: feeToken.id,
//                                       amount: BigUInt.zero,
//                                       fee: fee.fee.description,
//                                       nonce: nonce + 1,
//                                       tokenId: feeToken,
//                                       timeRange: timeRange)
//
//            let ethSignature = try self.ethSigner.signBatch(transactions: [transferNFT, transferFee],
//                                                   nonce: nonce,
//                                                   token: feeToken,
//                                                   fee: fee.fee)
//            let signedTransactions = [try self.zkSigner.sign(transfer: transferNFT),
//                                      try self.zkSigner.sign(transfer: transferFee)]
//            return self.submitSignedBatch(transactions: signedTransactions,
//                                          ethereumSignature: ethSignature)
//        }.pipe { (result) in
//            completion(result.result)
//        }
//    }
//}

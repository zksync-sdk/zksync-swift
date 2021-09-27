//
//  DefaultWallet+WithdrawNFT.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/05/2021.
//

import Foundation
import PromiseKit

extension DefaultWallet {

    public func withdrawNFT(to: String, token: NFT, fee: TransactionFee, nonce: UInt32?, timeRange: TimeRange, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        firstly {
            getNonceAccountIdPair(for: nonce)
        }.then { (nonce, accountId) in
            self.buildSignedWithdrawNFTTx(to: to,
                                          token: token,
                                          fee: fee,
                                          accountId: accountId,
                                          nonce: nonce,
                                          timeRange: timeRange)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: false)
        }.pipe { result in
            completion(result.result)
        }
    }
    
    func buildSignedWithdrawNFTTx(to: String,
                                  token: NFT,
                                  fee: TransactionFee,
                                  accountId: UInt32,
                                  nonce: UInt32,
                                  timeRange: TimeRange) -> Promise<SignedTransaction<WithdrawNFT>> {
        return firstly {
            self.getTokens()
        }.map { tokens in
            let feeToken = try tokens.tokenByTokenIdentifier(fee.feeToken)
            let withdrawNFT = WithdrawNFT(accountId: accountId,
                                          from: self.ethSigner.address,
                                          to: to,
                                          token: token.id,
                                          feeToken: feeToken.id,
                                          fee: fee.fee.description,
                                          nonce: nonce,
                                          timeRange: timeRange)
            
            let ethSignature = try self.ethSigner.signTransaction(transaction: withdrawNFT,
                                                                  nonce: nonce,
                                                                  token: feeToken,
                                                                  fee: fee.fee)
            
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(withdrawNFT: withdrawNFT), ethereumSignature: ethSignature)
            return signedTransaction
        }
    }
}

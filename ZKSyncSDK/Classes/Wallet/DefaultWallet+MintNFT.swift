//
//  DefaultWallet+MintNFT.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 20/05/2021.
//

import Foundation
import BigInt
import PromiseKit

extension DefaultWallet {
    
    public func mintNFT(recepient: String, contentHash: String, fee: TransactionFee, nonce: UInt32?, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        firstly {
            getNonceAccountIdPair(for: nonce)
        }.then { (nonce, accountId) in
            self.buildSignedMintNFTTx(recepient: recepient,
                                      contentHash: contentHash,
                                      fee: fee,
                                      accountId: accountId,
                                      nonce: nonce)
        }.then { signedTransaction in
            self.submitSignedTransaction(signedTransaction.transaction,
                                         ethereumSignature: signedTransaction.ethereumSignature,
                                         fastProcessing: false)
        }.pipe { result in
            completion(result.result)
        }
    }
    
    func buildSignedMintNFTTx(recepient: String, contentHash: String, fee: TransactionFee, accountId: UInt32, nonce: UInt32) -> Promise<SignedTransaction<MintNFT>>{
        return firstly {
            self.getTokens()
        }.map { tokens in
            let token = try tokens.tokenByTokenIdentifier(fee.feeToken)
            let mintNFT = MintNFT(creatorId: accountId,
                                  creatorAddress: self.ethSigner.address,
                                  contentHash: contentHash,
                                  recipient: recepient,
                                  fee: fee.fee.description,
                                  feeToken: token.id,
                                  nonce: nonce)
            let ethSignature = try self.ethSigner.signMintNFT(contentHash: contentHash, recepient: recepient, nonce: nonce, token: token, fee: fee.fee)
            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(mintNFT: mintNFT), ethereumSignature: ethSignature)
            return signedTransaction
            //SignedTransaction(
//            let token = try tokens.tokenByTokenIdentifier(tokenIdentifier)
//            let withdraw = Withdraw(accountId: accountId,
//                                    from: self.ethSigner.address,
//                                    to: to,
//                                    token: token.id,
//                                    amount: amount,
//                                    fee: fee.description,
//                                    nonce: nonce,
//                                    timeRange: timeRange)
//            let ethSignature = try self.ethSigner.signWithdraw(to: to, accountId: accountId, nonce: nonce, amount: amount, token: token, fee: fee)
//            let signedTransaction = SignedTransaction(transaction: try self.zkSigner.sign(withdraw: withdraw), ethereumSignature: ethSignature)
//            return signedTransaction
        }

    }
}

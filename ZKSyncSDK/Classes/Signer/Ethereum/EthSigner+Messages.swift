//
//  EthSigner+Messages.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation
import BigInt

public extension EthSigner {
    func createChangePubKeyMessage(pubKeyHash: String, nonce: UInt32, accountId: Int32) throws -> String {
        
        let pubKeyHashStripped = pubKeyHash.deletingPrefix("sync:").lowercased()
        
        return """
        Register zkSync pubkey:

        \(pubKeyHashStripped)
        nonce: \(try Utils.nonceToBytes(nonce).toHexString().addHexPrefix())
        account id: \(try Utils.accountIdToBytes(accountId).toHexString().addHexPrefix())

        Only sign this message for a trusted client!
        """
    }
    
    func createTransferMessage(to: String, accountId: Int32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) -> String {
        return """
        Transfer \(Utils.format(token.intoDecimal(amount))) \(token.symbol)
        To: \(to.lowercased())
        Nonce: \(nonce)
        Fee: \(Utils.format(token.intoDecimal(fee))) \(token.symbol)
        Account Id: \(accountId)
        """
    }

    func createWithdrawMessage(to: String, accountId: Int32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) -> String {
        return """
        Withdraw \(Utils.format(token.intoDecimal(amount))) \(token.symbol)
        To: \(to.lowercased())
        Nonce: \(nonce)
        Fee: \(Utils.format(token.intoDecimal(fee))) \(token.symbol)
        Account Id: \(accountId)
        """
    }
}

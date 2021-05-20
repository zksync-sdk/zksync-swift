//
//  EthSigner+Messages.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation
import BigInt

public extension DefaultEthSigner {

    func createChangePubKeyMessage(pubKeyHash: String, nonce: UInt32, accountId: UInt32, changePubKeyVariant: ChangePubKeyVariant) throws -> Data {
        var data = Data()
        data.append(try Utils.addressToBytes(pubKeyHash))
        data.append(Utils.nonceToBytes(nonce))
        data.append(try Utils.accountIdToBytes(accountId))
        data.append(changePubKeyVariant.bytes)
        return data
    }
    
    func createTransferMessage(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) -> Data {
        return String(format: "Transfer %@ %@ to: %@", Utils.format(token.intoDecimal(amount)), token.symbol, to.lowercased())
            .attaching(fee: fee, with: token)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }

    func createWithdrawMessage(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) -> Data {
        return String(format:"Withdraw %@ %@ to: %@", Utils.format(token.intoDecimal(amount)), token.symbol, to.lowercased())
            .attaching(fee: fee, with: token)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }

    func createForcedExitMessage(to: String, nonce: UInt32, token: Token, fee: BigUInt) -> Data {
        return String(format: "ForcedExit %@ to: %@", token.symbol, to.lowercased())
            .attaching(fee: fee, with: token)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }
    
    func createMintNFTMessage(contentHash: String, recepient: String, nonce: UInt32, token: Token, fee: BigUInt) -> Data {
        return String(format: "MintNFT %@ for: %@", contentHash, recepient.lowercased())
            .attaching(fee: fee, with: token)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }
}

fileprivate extension String {
    func attaching(fee: BigUInt, with token: Token) -> String {
        if fee > 0 {
            return self + String(format:"\nFee: %@ %@", Utils.format(token.intoDecimal(fee)), token.symbol);
        } else {
            return self
        }
    }
    
    func attaching(nonce: UInt32) -> String {
        return self + String(format: "\nNonce: %d", nonce)
    }
}

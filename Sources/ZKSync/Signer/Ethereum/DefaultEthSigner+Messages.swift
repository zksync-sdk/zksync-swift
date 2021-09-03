//
//  EthSigner+Messages.swift
//  ZKSync
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
    
    func createFullTransferMessage(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: TokenId, fee: BigUInt) -> Data {
        
        return self.createTransferMessagePart(to: to, accountId: accountId, amount: amount, token: token, fee: fee)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }
    
    func createTransferMessagePart(to: String, accountId: UInt32, amount: BigUInt, token: TokenId, fee: BigUInt) -> String {
        let message = !amount.isZero ? String(format: "Transfer %@ %@ to: %@", Utils.format(token.intoDecimal(amount)), token.symbol, to.lowercased()) : ""
        return message
            .attaching(fee: fee, with: token)
    }

    func createFullWithdrawMessage(to: String, accountId: UInt32, nonce: UInt32, amount: BigUInt, token: Token, fee: BigUInt) -> Data {
        return self.createWithdrawMessagePart(to: to, accountId: accountId, amount: amount, token: token, fee: fee)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }

    func createWithdrawMessagePart(to: String, accountId: UInt32, amount: BigUInt, token: Token, fee: BigUInt) -> String {
        return String(format:"Withdraw %@ %@ to: %@", Utils.format(token.intoDecimal(amount)), token.symbol, to.lowercased())
            .attaching(fee: fee, with: token)
    }
    
    func createFullForcedExitMessage(to: String, nonce: UInt32, token: Token, fee: BigUInt) -> Data {
        return self.createForcedExitMessagePart(to: to, token: token, fee: fee)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }

    func createForcedExitMessagePart(to: String, token: Token, fee: BigUInt) -> String {
        return String(format: "ForcedExit %@ to: %@", token.symbol, to.lowercased())
            .attaching(fee: fee, with: token)
    }

    func createFullMintNFTMessage(contentHash: String, recepient: String, nonce: UInt32, token: Token, fee: BigUInt) -> Data {
        return self.createMintNFTMessagePart(contentHash: contentHash, recepient: recepient, token: token, fee: fee)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }

    func createMintNFTMessagePart(contentHash: String, recepient: String, token: Token, fee: BigUInt) -> String {
        return String(format: "MintNFT %@ for: %@", contentHash, recepient.lowercased())
            .attaching(fee: fee, with: token)
    }

    func createFullWithdrawNFTMessage(to: String, tokenId: UInt32, nonce: UInt32, token: Token, fee: BigUInt) -> Data {
        return self.createWithdrawNFTMessagePart(to: to, tokenId: tokenId, token: token, fee: fee)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }

    func createWithdrawNFTMessagePart(to: String, tokenId: UInt32, token: Token, fee: BigUInt) -> String {
        return String(format: "WithdrawNFT %d to: %@", tokenId, to.lowercased())
            .attaching(fee: fee, with: token)
    }
    
    func createFullSwapMessage(nonce: UInt32, token: Token, fee: BigUInt) -> Data {
        return self.createSwapMessagePart(token: token, fee: fee)
            .attaching(nonce: nonce)
            .data(using: .utf8)!
    }
    
    func createSwapMessagePart(token: Token, fee: BigUInt) -> String {
        return String(format: "Swap fee: %@ %@", Utils.format(token.intoDecimal(fee)), token.symbol)
    }
    
    func createFullOrderMessage(recepient: String, amount: BigUInt, tokenSell: Token, tokenBuy: Token, ratio: (BigUInt, BigUInt), nonce: UInt32) -> Data {
        var result = ""
        if amount == .zero {
            result = String(format: "Limit order for %@ -> %@", tokenSell.symbol, tokenBuy.symbol)
        } else {
            result = String(format: "Order for %@ %@ -> %@",
                            Utils.format(tokenSell.intoDecimal(amount)),
                            tokenSell.symbol,
                            tokenBuy.symbol)
        }
        result += String(format: "\nRatio: %@:%@\nAddress: %@", ratio.0.description, ratio.1.description, recepient.lowercased())
        return result.attaching(nonce: nonce).data(using: .utf8)!
    }
    
    func createToggle2FAMessage(require2FA: Bool, timestamp: Int64) -> String {
        var message = ""
        
        if require2FA {
            message = String(format:
                                "By signing this message, you are opting into Two-factor Authentication protection by the zkSync Server.\n" +
                                "Transactions now require signatures by both your L1 and L2 private key.\n" +
                                "Timestamp: %lu", timestamp)
        } else {
            message = String(format:
                                "You are opting out of Two-factor Authentication protection by the zkSync Server.\n" +
                                "Transactions now only require signatures by your L2 private key.\n" +
                                "BY SIGNING THIS MESSAGE, YOU ARE TRUSTING YOUR WALLET CLIENT TO KEEP YOUR L2 PRIVATE KEY SAFE!\n" +
                                "Timestamp: %lu", timestamp)
        }
        
        return message
    }
}

internal extension String {
    func attaching(fee: BigUInt, with token: TokenId) -> String {
        if fee > 0 {
            let separator = self.isEmpty ? "" : "\n"
            return self + separator + String(format:"Fee: %@ %@", Utils.format(token.intoDecimal(fee)), token.symbol);
        } else {
            return self
        }
    }
    
    func attaching(nonce: UInt32) -> String {
        return self + String(format: "\nNonce: %d", nonce)
    }
}

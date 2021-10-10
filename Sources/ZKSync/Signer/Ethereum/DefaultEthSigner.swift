//
//  DefaultEthSigner.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 22/01/2021.
//

import Foundation
import BigInt

public class DefaultEthSigner: EthSigner {

    // swiftlint:disable:next type_name
    public typealias A = ChangePubKeyECDSA

    var privateKey: Data

    public init(privateKey: String) throws {
        self.privateKey = Data(hex: privateKey)
    }

    public func signAuth(changePubKey: ChangePubKey<ChangePubKeyECDSA>) throws -> ChangePubKey<ChangePubKeyECDSA> {
        let batchHash = Data(repeating: 0, count: 32).toHexString().addHexPrefix()
        var auth = ChangePubKeyECDSA(ethSignature: nil, batchHash: batchHash)

        let message = try createChangePubKeyMessage(pubKeyHash: changePubKey.newPkHash,
                                                    nonce: changePubKey.nonce,
                                                    accountId: changePubKey.accountId,
                                                    changePubKeyVariant: auth)

        let ethSignature = try sign(message: message)

        auth.ethSignature = ethSignature.signature
        changePubKey.ethAuthData = auth

        return changePubKey
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func signTransaction<T>(transaction: T,
                                   nonce: UInt32,
                                   token: Token,
                                   fee: BigUInt) throws -> EthSignature? where T: ZkSyncTransaction {
        switch transaction.type {
        case "ChangePubKey":
            guard let transaction = transaction as? ChangePubKey<ChangePubKeyECDSA> else {
                throw EthSignerError.invalidTransactionType("Unexpected transaction type: \(transaction.type).")
            }

            let message = try createChangePubKeyMessage(pubKeyHash: transaction.newPkHash,
                                                        nonce: nonce,
                                                        accountId: transaction.accountId,
                                                        changePubKeyVariant: transaction.ethAuthData!)

            return try sign(message: message)
        case "ForcedExit":
            guard let transaction = transaction as? ForcedExit else {
                throw EthSignerError.invalidTransactionType("Unexpected transaction type: \(transaction.type).")
            }

            let message = createFullForcedExitMessage(to: transaction.target,
                                                      nonce: nonce,
                                                      token: token,
                                                      fee: fee)

            return try sign(message: message)
        case "MintNFT":
            guard let transaction = transaction as? MintNFT else {
                throw EthSignerError.invalidTransactionType("Unexpected transaction type: \(transaction.type).")
            }

            let message = createFullMintNFTMessage(contentHash: transaction.contentHash,
                                                   recepient: transaction.recipient,
                                                   nonce: nonce,
                                                   token: token,
                                                   fee: fee)

            return try sign(message: message)
        case "Transfer":
            guard let transaction = transaction as? Transfer else {
                throw EthSignerError.invalidTransactionType("Unexpected transaction type: \(transaction.type).")
            }

            let message = createFullTransferMessage(to: transaction.to,
                                                    accountId: transaction.accountId,
                                                    nonce: nonce,
                                                    amount: transaction.amount,
                                                    token: token,
                                                    fee: fee)

            return try sign(message: message)
        case "Withdraw":
            guard let transaction = transaction as? Withdraw else {
                throw EthSignerError.invalidTransactionType("Unexpected transaction type: \(transaction.type).")
            }

            let message = createFullWithdrawMessage(to: transaction.to,
                                                    accountId: transaction.accountId,
                                                    nonce: nonce,
                                                    amount: transaction.amount,
                                                    token: token,
                                                    fee: fee)

            return try sign(message: message)
        case "WithdrawNFT":
            guard let transaction = transaction as? WithdrawNFT else {
                throw EthSignerError.invalidTransactionType("Unexpected transaction type: \(transaction.type).")
            }

            let message = createFullWithdrawNFTMessage(to: transaction.to,
                                                       tokenId: transaction.token,
                                                       nonce: nonce,
                                                       token: token,
                                                       fee: fee)

            return try sign(message: message)
        case "Swap":
            guard transaction is Swap else {
                throw EthSignerError.invalidTransactionType("Unexpected transaction type: \(transaction.type).")
            }

            let message = createFullSwapMessage(nonce: nonce,
                                                token: token,
                                                fee: fee)

            return try sign(message: message)
        default:
            throw EthSignerError.invalidTransactionType("Transaction type \(transaction.type) is not supported.")
        }
    }

    public func signOrder(_ order: Order,
                          tokenSell: Token,
                          tokenBuy: Token) throws -> EthSignature {
        let message = createFullOrderMessage(recepient: order.recepientAddress,
                                             amount: order.amount,
                                             tokenSell: tokenSell,
                                             tokenBuy: tokenBuy,
                                             ratio: order.ratio,
                                             nonce: order.nonce)
        return try sign(message: message)
    }

    public func signBatch(transactions: [ZkSyncTransaction],
                          nonce: UInt32,
                          token: Token,
                          fee: BigUInt) throws -> EthSignature {
        let message =
            try transactions.map { (tx) -> String in
                switch tx {
                case let forcedExitTx as ForcedExit:
                    return createForcedExitMessagePart(to: forcedExitTx.target,
                                                       token: token,
                                                       fee: fee)
                case let mintNFTTx as MintNFT:
                    return createMintNFTMessagePart(contentHash: mintNFTTx.contentHash,
                                                    recepient: mintNFTTx.recipient,
                                                    token: token,
                                                    fee: fee)
                case let transferTx as Transfer:
                    let tokenId = transferTx.tokenId ?? token
                    return createTransferMessagePart(to: transferTx.to,
                                                     accountId: transferTx.accountId,
                                                     amount: transferTx.amount,
                                                     token: tokenId,
                                                     fee: BigUInt(stringLiteral: transferTx.fee))
                case let withdrawTx as Withdraw:
                    return createWithdrawMessagePart(to: withdrawTx.to,
                                                     accountId: withdrawTx.accountId,
                                                     amount: withdrawTx.amount,
                                                     token: token,
                                                     fee: fee)
                case let withdrawNFTTx as WithdrawNFT:
                    return createWithdrawNFTMessagePart(to: withdrawNFTTx.to,
                                                        tokenId: withdrawNFTTx.token,
                                                        token: token,
                                                        fee: fee)
                case is Swap:
                    return createSwapMessagePart(token: token,
                                                 fee: fee)
                default:
                    throw EthSignerError.invalidTransactionType("Transaction type \(tx.type) is not supported by batch")
                }
            }
            .joined(separator: "\n")
            .attaching(nonce: nonce)
            .data(using: .utf8)!

        return try sign(message: message)
    }

    func hashPersonalMessage(_ personalMessage: Data) -> Data? {
        var prefix = "\u{19}Ethereum Signed Message:\n"
        prefix += String(personalMessage.count)
        guard let prefixData = prefix.data(using: .ascii) else {return nil}
        var data = Data()
        if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
            data.append(personalMessage)
        } else {
            data.append(prefixData)
            data.append(personalMessage)
        }
        let hash = data.sha3(.keccak256)
        return hash
    }

    public func sign(message: Data) throws -> EthSignature {

        guard let hash = hashPersonalMessage(message) else {
            throw EthSignerError.signingFailed
        }

        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash,
                                                                 privateKey: privateKey)

        guard let validSignatureData = compressedSignature else {
            throw EthSignerError.signingFailed
        }

        return EthSignature(signature: validSignatureData.toHexString().addHexPrefix(),
                            type: .ethereumSignature)
    }

    public func verify(_ signature: EthSignature, message: Data) throws -> Bool {
        let signatureData = Data(hex: signature.signature)

        guard let hash = hashPersonalMessage(message) else {
            throw EthSignerError.invalidMessage
        }

        let publicKeyData = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData)

        let keystorePublicKeyData = SECP256K1.privateToPublic(privateKey: privateKey)

        return publicKeyData == keystorePublicKeyData
    }

    public func signToggle(_ enable: Bool, timestamp: Int64) throws -> EthSignature {
        let message = createToggle2FAMessage(require2FA: enable, timestamp: timestamp)

        return try sign(message: message.data(using: .utf8)!)
    }
}

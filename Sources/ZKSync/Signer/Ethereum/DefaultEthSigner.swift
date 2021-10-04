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

    public let keystore: AbstractKeystore

    public var address: String {
        return ethereumAddress.address.lowercased()
    }

    public var ethereumAddress: EthereumAddress {
        return keystore.addresses!.first!
    }

    public init(privateKey: String) throws {
        let privatKeyData = Data(hex: privateKey)
        guard let keystore = try EthereumKeystoreV3(privateKey: privatKeyData) else {
            throw EthSignerError.invalidKey
        }
        self.keystore = keystore
    }

    public init(mnemonic: String) throws {
        guard let keystore = try BIP32Keystore(mnemonics: mnemonic) else {
            throw EthSignerError.invalidMnemonic
        }
        self.keystore = keystore
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

    public func sign(message: Data) throws -> EthSignature {

        var signatureData: Data?

        if let keystore = keystore as? EthereumKeystoreV3 {
            signatureData = try Web3Signer.signPersonalMessage(message,
                                                               keystore: keystore,
                                                               account: ethereumAddress,
                                                               password: "web3swift")
        } else if let keystore = keystore as? BIP32Keystore {
            signatureData = try Web3Signer.signPersonalMessage(message,
                                                               keystore: keystore,
                                                               account: ethereumAddress,
                                                               password: "web3swift")
        }

        guard let validSignatureData = signatureData else {
            throw EthSignerError.signingFailed
        }

        return EthSignature(signature: validSignatureData.toHexString().addHexPrefix(),
                            type: .ethereumSignature)
    }

    public func verifySignature(_ signature: EthSignature, message: Data) throws -> Bool {
        let signatureData = Data(hex: signature.signature)
        guard let hash = Web3Utils.hashPersonalMessage(message) else {
            throw EthSignerError.invalidMessage
        }

        let publicKeyData = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData)

        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: "web3swift",
                                                               account: ethereumAddress)
        defer { Data.zero(&privateKey) }

        let keystorePublicKeyData = Web3Utils.privateToPublic(privateKey)

        return publicKeyData == keystorePublicKeyData
    }

    public func signToggle(_ enable: Bool, timestamp: Int64) throws -> EthSignature {
        let message = createToggle2FAMessage(require2FA: enable, timestamp: timestamp)

        return try sign(message: message.data(using: .utf8)!)
    }
}

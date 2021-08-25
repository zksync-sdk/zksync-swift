//
//  ZkSigner.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation
import CryptoSwift
import ZKSyncCrypto

enum ZkSignerError: Error {
    case invalidPrivateKey
    case incorrectDataLength
}

public class ZkSigner {
    
    private static let Message = "Access zkSync account.\n\nOnly sign this message for a trusted client!"
    private static let TransactionVersion: UInt8 = 0x01
    
    let privateKey: ZKPrivateKey
    let publicKey: ZKPackedPublicKey
    public let publicKeyHash: String
    
    public init(privateKey: ZKPrivateKey) throws {
        self.privateKey = privateKey
        
        switch ZKSyncCrypto.getPublicKey(privateKey: privateKey) {
        case .success(let key):
            self.publicKey = key
        default:
            throw ZkSignerError.invalidPrivateKey
        }
        
        switch ZKSyncCrypto.getPublicKeyHash(publicKey: self.publicKey) {
        case .success(let hash):
            self.publicKeyHash = hash.hexEncodedString().addPubKeyHashPrefix().lowercased()
        default:
            throw ZkSignerError.invalidPrivateKey
        }
    }
    
    public convenience init(seed: Data) throws {
        switch ZKSyncCrypto.generatePrivateKey(seed: seed) {
        case .success(let privateKey):
            try self.init(privateKey: privateKey)
        case .failure(let error):
            throw error
        }
    }
    
    public convenience init(rawPrivateKey: Data) throws {
        if rawPrivateKey.count != ZKPrivateKey.bytesLength {
            throw ZkSignerError.incorrectDataLength
        }
        try self.init(privateKey: ZKPrivateKey(rawPrivateKey))
    }
    
    public convenience init(ethSigner: EthSigner, chainId: ChainId) throws {
        var message = ZkSigner.Message
        if chainId != .mainnet {
            message = "\(message)\nChain ID: \(chainId.id)."
        }
        let signature = try ethSigner.sign(message: message.data(using: .utf8)!)
        
        try self.init(seed: Data(hex: signature.signature))
    }
    
    public func sign(message: Data) throws -> Signature {
        switch ZKSyncCrypto.signMessage(privateKey: self.privateKey, message: message) {
        case .success(let signature):
            return Signature(pubKey: publicKey.hexEncodedString().lowercased(),
                             signature: signature.hexEncodedString().lowercased())
        case .failure(let error):
            throw error
        }
    }
    
    public func sign<T: ChangePubKeyVariant>(changePubKey: ChangePubKey<T>) throws -> ChangePubKey<T> {
        changePubKey.signature = try compileSignature {
            0xff - 0x07
            ZkSigner.TransactionVersion
            try Utils.accountIdToBytes(changePubKey.accountId)
            try Utils.addressToBytes(changePubKey.account)
            try Utils.addressToBytes(changePubKey.newPkHash)
            try Utils.tokenIdToBytes(changePubKey.feeToken)
            try Utils.feeToBytes(changePubKey.feeInteger)
            Utils.nonceToBytes(changePubKey.nonce)
            Utils.numberToBytesBE(changePubKey.timeRange.validFrom, numBytes: 8)
            Utils.numberToBytesBE(changePubKey.timeRange.validUntil, numBytes: 8)
        }
        return changePubKey
    }
    
    public func sign(transfer: Transfer) throws -> Transfer {
        transfer.signature = try compileSignature {
            0xff - 0x05
            ZkSigner.TransactionVersion
            try Utils.accountIdToBytes(transfer.accountId)
            try Utils.addressToBytes(transfer.from)
            try Utils.addressToBytes(transfer.to)
            try Utils.tokenIdToBytes(transfer.token)
            try Utils.amountPackedToBytes(transfer.amount)
            try Utils.feeToBytes(transfer.feeInteger)
            Utils.nonceToBytes(transfer.nonce)
            Utils.numberToBytesBE(transfer.timeRange.validFrom, numBytes: 8)
            Utils.numberToBytesBE(transfer.timeRange.validUntil, numBytes: 8)
        }
        return transfer
    }

    public func sign(withdraw: Withdraw) throws -> Withdraw {
        withdraw.signature = try self.compileSignature {
            0xff - 0x03
            ZkSigner.TransactionVersion
            try Utils.accountIdToBytes(withdraw.accountId)
            try Utils.addressToBytes(withdraw.from)
            try Utils.addressToBytes(withdraw.to)
            try Utils.tokenIdToBytes(withdraw.token)
            Utils.amountFullToBytes(withdraw.amount)
            try Utils.feeToBytes(withdraw.feeInteger)
            Utils.nonceToBytes(withdraw.nonce)
            Utils.numberToBytesBE(withdraw.timeRange.validFrom, numBytes: 8)
            Utils.numberToBytesBE(withdraw.timeRange.validUntil, numBytes: 8)
        }
        return withdraw
    }

    public func sign(forcedExit: ForcedExit) throws -> ForcedExit {
        forcedExit.signature = try compileSignature {
            0xff - 0x08
            ZkSigner.TransactionVersion
            try Utils.accountIdToBytes(forcedExit.initiatorAccountId)
            try Utils.addressToBytes(forcedExit.target)
            try Utils.tokenIdToBytes(forcedExit.token)
            try Utils.feeToBytes(forcedExit.feeInteger)
            Utils.nonceToBytes(forcedExit.nonce)
            Utils.numberToBytesBE(forcedExit.timeRange.validFrom, numBytes: 8)
            Utils.numberToBytesBE(forcedExit.timeRange.validUntil, numBytes: 8)
        }
        return forcedExit
    }
    
    public func sign(mintNFT: MintNFT) throws -> MintNFT {
        mintNFT.signature = try compileSignature {
            0xff - 0x09
            ZkSigner.TransactionVersion
            try Utils.accountIdToBytes(mintNFT.creatorId)
            try Utils.addressToBytes(mintNFT.creatorAddress)
            Data.fromHex(mintNFT.contentHash)!
            try Utils.addressToBytes(mintNFT.recipient)
            try Utils.tokenIdToBytes(mintNFT.feeToken)
            try Utils.feeToBytes(mintNFT.feeInteger)
            Utils.nonceToBytes(mintNFT.nonce)
        }
        return mintNFT
    }
    
    public func sign(withdrawNFT: WithdrawNFT) throws -> WithdrawNFT {
        withdrawNFT.signature = try compileSignature {
            0xff - 0x0a
            ZkSigner.TransactionVersion
            try Utils.accountIdToBytes(withdrawNFT.accountId)
            try Utils.addressToBytes(withdrawNFT.from)
            try Utils.addressToBytes(withdrawNFT.to)
            try Utils.tokenIdToBytes(withdrawNFT.token)
            try Utils.tokenIdToBytes(withdrawNFT.feeToken)
            try Utils.feeToBytes(withdrawNFT.feeInteger)
            Utils.nonceToBytes(withdrawNFT.nonce)
            Utils.numberToBytesBE(withdrawNFT.timeRange.validFrom, numBytes: 8)
            Utils.numberToBytesBE(withdrawNFT.timeRange.validUntil, numBytes: 8)
        }
        return withdrawNFT
    }
    
    public func sign(swap: Swap) throws -> Swap {
        
        let order1Data = try self.data(from: swap.orders.0)
        let order2Data = try self.data(from: swap.orders.1)
        
        var orderMessage = Data()
        orderMessage.append(order1Data)
        orderMessage.append(order2Data)
        
        let rescueHash = ZKSyncCrypto.rescueHashOrders(message: orderMessage)
        
        swap.signature = try compileSignature {
            0xff - 0x0b
            ZkSigner.TransactionVersion
            try Utils.accountIdToBytes(swap.submitterId)
            try Utils.addressToBytes(swap.submitterAddress)
            Utils.nonceToBytes(swap.nonce)
            rescueHash.data()
            try Utils.tokenIdToBytes(swap.feeToken)
            try Utils.feeToBytes(swap.feeInteger)
            try Utils.amountPackedToBytes(swap.amounts.0)
            try Utils.amountPackedToBytes(swap.amounts.1)
        }
        
        return swap
    }
    
    func sign(order: Order) throws -> Order {
        var mutableOrder = order
        let message = try self.data(from: order)
        mutableOrder.signature = try self.sign(message: message)
        return mutableOrder
    }
    
    func data(from order: Order) throws -> Data {
        return try compileMessage {
            0x6f
            ZkSigner.TransactionVersion
            try Utils.accountIdToBytes(order.accountId)
            try Utils.addressToBytes(order.recepientAddress)
            Utils.nonceToBytes(order.nonce)
            try Utils.tokenIdToBytes(order.tokenSell)
            try Utils.tokenIdToBytes(order.tokenBuy)
            Utils.numberToBytesBE(order.ratio.0, numBytes: 15)
            Utils.numberToBytesBE(order.ratio.1, numBytes: 15)
            try Utils.amountPackedToBytes(order.amount)
            Utils.numberToBytesBE(order.timeRange.validFrom, numBytes: 8)
            Utils.numberToBytesBE(order.timeRange.validUntil, numBytes: 8)
        }
    }
    
    func compileMessage(@MessageBuilder content: () throws -> Data) rethrows -> Data {
        return try content()
    }
    
    func compileSignature(@MessageBuilder content: () throws -> Data) throws -> Signature {
        return try self.sign(message: try content())
    }
}


@resultBuilder
struct MessageBuilder {
    static func buildBlock(_ components: Data...) -> Data {
        components.reduce(into: Data()) { (result, data) in
            result.append(data)
        }
    }
    
    static func buildExpression(_ element: UInt8) -> Data {
        return Data([element])
    }
    
    static func buildExpression(_ element: Data) -> Data {
        return element
    }
}

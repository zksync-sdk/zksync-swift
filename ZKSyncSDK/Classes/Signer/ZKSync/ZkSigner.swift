//
//  ZkSigner.swift
//  ZKSyncSDK
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
    
    let privateKey: ZKPrivateKey
    let publicKey: ZKPackedPublicKey
    public let publicKeyHash: String
    
    public init(privateKey: ZKPrivateKey) throws {
        self.privateKey = privateKey
        
        switch ZKSyncSDK.getPublicKey(privateKey: privateKey) {
        case .success(let key):
            self.publicKey = key
        default:
            throw ZkSignerError.invalidPrivateKey
        }
        
        switch ZKSyncSDK.getPublicKeyHash(publicKey: self.publicKey) {
        case .success(let hash):
            self.publicKeyHash = hash.hexEncodedString().addPubKeyHashPrefix().lowercased()
        default:
            throw ZkSignerError.invalidPrivateKey
        }
    }
    
    public convenience init(seed: Data) throws {
        switch ZKSyncSDK.generatePrivateKey(seed: seed) {
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
        switch ZKSyncSDK.signMessage(privateKey: self.privateKey, message: message) {
        case .success(let signature):
            return Signature(pubKey: publicKey.hexEncodedString().lowercased(),
                             signature: signature.hexEncodedString().lowercased())
        case .failure(let error):
            throw error
        }
    }
    
    public func sign<T: ChangePubKeyVariant>(changePubKey: ChangePubKey<T>) throws -> ChangePubKey<T> {
        var data = Data()
        
        data.append(contentsOf: [0x07])
        data.append(try Utils.accountIdToBytes(changePubKey.accountId))
        data.append(try Utils.addressToBytes(changePubKey.account))
        data.append(try Utils.addressToBytes(changePubKey.newPkHash))
        data.append(try Utils.tokenIdToBytes(changePubKey.feeToken))
        data.append(try Utils.feeToBytes(changePubKey.feeInteger))
        data.append(Utils.nonceToBytes(changePubKey.nonce))
        data.append(Utils.numberToBytesBE(changePubKey.timeRange.validFrom, numBytes: 8))
        data.append(Utils.numberToBytesBE(changePubKey.timeRange.validUntil, numBytes: 8))
        
        let signature = try self.sign(message: data)
        changePubKey.signature = signature
        return changePubKey
    }
    
    public func sign(transfer: Transfer) throws -> Transfer {
        var data = Data()
        
        data.append(contentsOf: [0x05])
        data.append(try Utils.accountIdToBytes(transfer.accountId))
        data.append(try Utils.addressToBytes(transfer.from))
        data.append(try Utils.addressToBytes(transfer.to))
        data.append(try Utils.tokenIdToBytes(transfer.token))
        data.append(try Utils.amountPackedToBytes(transfer.amount))
        data.append(try Utils.feeToBytes(transfer.feeInteger))
        data.append(Utils.nonceToBytes(transfer.nonce))
        data.append(Utils.numberToBytesBE(transfer.timeRange.validFrom, numBytes: 8))
        data.append(Utils.numberToBytesBE(transfer.timeRange.validUntil, numBytes: 8))

        let signature = try self.sign(message: data)
        transfer.signature = signature
        return transfer
    }

    public func sign(withdraw: Withdraw) throws -> Withdraw {
        var data = Data()
        
        data.append(contentsOf: [0x03])
        data.append(try Utils.accountIdToBytes(withdraw.accountId))
        data.append(try Utils.addressToBytes(withdraw.from))
        data.append(try Utils.addressToBytes(withdraw.to))
        data.append(try Utils.tokenIdToBytes(withdraw.token))
        data.append(Utils.amountFullToBytes(withdraw.amount))
        data.append(try Utils.feeToBytes(withdraw.feeInteger))
        data.append(Utils.nonceToBytes(withdraw.nonce))
        data.append(Utils.numberToBytesBE(withdraw.timeRange.validFrom, numBytes: 8))
        data.append(Utils.numberToBytesBE(withdraw.timeRange.validUntil, numBytes: 8))

        let signature = try self.sign(message: data)
        withdraw.signature = signature
        return withdraw
    }

    public func sign(forcedExit: ForcedExit) throws -> ForcedExit {
        var data = Data()
        
        data.append(contentsOf: [0x08])
        data.append(try Utils.accountIdToBytes(forcedExit.initiatorAccountId))
        data.append(try Utils.addressToBytes(forcedExit.target))
        data.append(try Utils.tokenIdToBytes(forcedExit.token))
        data.append(try Utils.feeToBytes(forcedExit.feeInteger))
        data.append(Utils.nonceToBytes(forcedExit.nonce))
        data.append(Utils.numberToBytesBE(forcedExit.timeRange.validFrom, numBytes: 8))
        data.append(Utils.numberToBytesBE(forcedExit.timeRange.validUntil, numBytes: 8))

        let signature = try self.sign(message: data)
        forcedExit.signature = signature
        return forcedExit
    }
    
    public func sign(mintNFT: MintNFT) throws -> MintNFT {
        var data = Data()
        
        data.append(contentsOf: [0x09])
        data.append(try Utils.accountIdToBytes(mintNFT.creatorId))
        data.append(try Utils.addressToBytes(mintNFT.creatorAddress))
        data.append(Data.fromHex(mintNFT.contentHash)!)
        data.append(try Utils.addressToBytes(mintNFT.recipient))
        data.append(try Utils.tokenIdToBytes(mintNFT.feeToken))
        data.append(try Utils.feeToBytes(mintNFT.feeInteger))
        data.append(Utils.nonceToBytes(mintNFT.nonce))
        
        let signature = try self.sign(message: data)
        mintNFT.signature = signature
        return mintNFT
    }
    
    public func sign(withdrawNFT: WithdrawNFT) throws -> WithdrawNFT {
        //let mutableWithdrawNFT = withdrawNFT
        var data = Data()
        
        data.append(contentsOf: [0x0a])
        data.append(try Utils.accountIdToBytes(withdrawNFT.accountId))
        data.append(try Utils.addressToBytes(withdrawNFT.from))
        data.append(try Utils.addressToBytes(withdrawNFT.to))
        data.append(try Utils.tokenIdToBytes(withdrawNFT.token))
        data.append(try Utils.tokenIdToBytes(withdrawNFT.feeToken))
        data.append(try Utils.feeToBytes(withdrawNFT.feeInteger))
        data.append(Utils.nonceToBytes(withdrawNFT.nonce))
        data.append(Utils.numberToBytesBE(withdrawNFT.timeRange.validFrom, numBytes: 8))
        data.append(Utils.numberToBytesBE(withdrawNFT.timeRange.validUntil, numBytes: 8))

        let signature = try self.sign(message: data)
        withdrawNFT.signature = signature
        return withdrawNFT
    }
    
    public func sign(swap: Swap) throws -> Swap {
        
        var data = Data()
        
        let order1Data = try self.data(from: swap.orders.0)
        let order2Data = try self.data(from: swap.orders.1)
        
        data.append(contentsOf: [0x0b])
        data.append(try Utils.accountIdToBytes(swap.submitterId))
        data.append(try Utils.addressToBytes(swap.submitterAddress))
        data.append(Utils.nonceToBytes(swap.nonce))
        data.append(order1Data)
        data.append(order2Data)
        data.append(try Utils.tokenIdToBytes(swap.feeToken))
        data.append(try Utils.amountPackedToBytes(swap.amounts.0))
        data.append(try Utils.amountPackedToBytes(swap.amounts.1))
        data.append(try Utils.feeToBytes(swap.feeInteger))
        
        let signature = try sign(message: data)
        
        swap.orders.0.signature = try sign(message: order1Data)
        swap.orders.1.signature = try sign(message: order2Data)
        swap.signature = signature
        
        return swap
    }
    
    func data(from order: Order) throws -> Data {
        var data = Data()

        data.append(contentsOf: [0x30])
        data.append(try Utils.accountIdToBytes(order.accountId))
        data.append(try Utils.addressToBytes(order.recepientAddress))
        data.append(Utils.nonceToBytes(order.nonce))
        data.append(try Utils.tokenIdToBytes(order.tokenSell))
        data.append(try Utils.tokenIdToBytes(order.tokenBuy))
        data.append(Utils.numberToBytesBE(order.ratio.0, numBytes: 15))
        data.append(Utils.numberToBytesBE(order.ratio.1, numBytes: 15))
        data.append(Utils.amountFullToBytes(order.amount))
        data.append(Utils.numberToBytesBE(order.timeRange.validFrom, numBytes: 8))
        data.append(Utils.numberToBytesBE(order.timeRange.validUntil, numBytes: 8))

        return data
    }
}

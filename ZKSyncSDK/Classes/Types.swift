//
//  Types.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

public enum Network {
    case localhost, rinkeby, ropsten, mainnet
    
    var address: String {
        switch self {
        case .localhost:
            return "http://127.0.0.1:3030"
        case .rinkeby:
            return "https://rinkeby-api.zksync.io/jsrpc"
        case .ropsten:
            return "https://ropsten-api.zksync.io/jsrpc"
        case .mainnet:
            return "https://api.zksync.io/jsrpc"
        }
    }
}

public typealias ZKSyncResult<T> = Result<T, ZKSyncError>

public enum ZKSyncError: Error {
    case networkNotSupported(_ info: String)
    case malformedRequest
    case malformedResponse
    
    case rpcError(code: Int, message: String)
}



enum VerificationMethod {
    case ECDSA, ERC1271
}

struct EthSignerType {
    var verificationMethod: VerificationMethod
    var signedMsgPrefixed: Bool
}

enum TxEhSignature {
    case Ethereum(signature: String)
    case EIP1271(signature: String)
}

struct Signature {
    var pubKey: String
    var signature: String
}

struct Transfer {
    var accountId: Int
    var from: String
    var to: String
    var token: Int
    var amount: Int
    var fee: Int
    var nonce: Int
}

struct Withdraw {
    
}


extension String {
    func stripHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
    
    func addHexPrefix() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
}

extension BigUInt {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let stringValue = try container.decode(String.self)
        
        self.init(stringValue.stripHexPrefix(), radix: 16)!
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(String(self, radix: 16).addHexPrefix())
    }
}

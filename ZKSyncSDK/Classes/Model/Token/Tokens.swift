//
//  Tokens.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 13/01/2021.
//

import Foundation

public enum TokensError: Error {
    case noTokenWithAddress(String)
}

public struct Tokens: Decodable {
    private var tokens: [String: Token]

    public func tokenBySymbol(_ symbol: String) -> Token? {
        return tokens[symbol]
    }
    
    public func tokenByAddress(_ address: String) throws -> Token {
        let record = tokens.first { (key, token) -> Bool in
            return token.address == address
        }
        guard let token = record?.value else {
            throw TokensError.noTokenWithAddress(address)
        }
        return token
    }
    
    public func tokenByTokenIdentifier(_ identifier: String) throws -> Token {
        guard let symbol = tokenBySymbol(identifier) else {
            return try tokenByAddress(identifier)
        }
        return symbol
    }
    
    public init(from decoder: Decoder) throws {
        tokens = [:]
        let container = try decoder.container(keyedBy: DynamicKey.self)
        for key in container.allKeys {
            tokens[key.stringValue] = try container.decode(Token.self, forKey: key)
        }
    }
    
    internal init(tokens: [String: Token]) {
        self.tokens = tokens
    }

    struct DynamicKey: CodingKey {
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }
}

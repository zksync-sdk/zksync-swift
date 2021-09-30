//
//  String+Extensions.swift
//  ZKSync
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

extension String {

    func hasHexPrefix() -> Bool {
        return self.hasPrefix("0x")
    }

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

extension String {

    func hasPubKeyHashPrefix() -> Bool {
        return self.hasPrefix("sync:")
    }

    func stripPubKeyHashPrefix() -> String {
        return self.deletingPrefix("sync:")
    }

    func addPubKeyHashPrefix() -> String {
        if !self.hasPrefix("sync:") {
            return "sync:" + self
        }
        return self
    }
}

extension String {

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension String {

    func attaching(fee: BigUInt, with token: TokenId) -> String {
        if fee > 0 {
            let separator = self.isEmpty ? "" : "\n"
            return self + separator + String(format: "Fee: %@ %@",
                                             Utils.format(token.intoDecimal(fee)),
                                             token.symbol)
        } else {
            return self
        }
    }

    func attaching(nonce: UInt32) -> String {
        return self + String(format: "\nNonce: %d", nonce)
    }
}

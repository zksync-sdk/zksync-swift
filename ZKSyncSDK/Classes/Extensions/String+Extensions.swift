//
//  String+Extensions.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

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

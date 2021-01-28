//
//  BinaryInteger+Extensions.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation

extension BinaryInteger {
    func bytes() -> Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
    
}

extension FixedWidthInteger {
    func bytesBE() -> Data {
        return self.bigEndian.bytes()
    }
}

extension UInt8 {
    var bitReversed: UInt8 {
        var byte = self
        byte = ((byte & 0xf0) >> 4) | ((byte & 0x0f) << 4)
        byte = ((byte & 0xcc) >> 2) | ((byte & 0x33) << 2)
        byte = ((byte & 0xaa) >> 1) | ((byte & 0x55) << 1)
        return byte
    }
}

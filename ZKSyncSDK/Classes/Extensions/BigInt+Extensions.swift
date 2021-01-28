//
//  BigInt+Extensions.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation
import BigInt

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
    
    static var ten: BigUInt {
        return BigUInt(10)
    }
    
    static var two: BigUInt {
        return BigUInt(2)
    }

    static var one: BigUInt {
        return BigUInt(1)
    }
    
    static var zero: BigUInt {
        return BigUInt(0)
    }
}

extension BigInt {
    public func serialize() -> Data {
            // This assumes Digit is binary.
            precondition(Word.bitWidth % 8 == 0)

            let byteCount = (self.bitWidth + 7) / 8

            guard byteCount > 0 else { return Data() }

            var data = Data(count: byteCount)
            data.withUnsafeMutableBytes { buffPtr in
                let p = buffPtr.bindMemory(to: UInt8.self)
                var i = byteCount - 1
                for var word in self.words {
                    for _ in 0 ..< Word.bitWidth / 8 {
                        p[i] = UInt8(word & 0xFF)
                        word >>= 8
                        if i == 0 {
                            assert(word == 0)
                            break
                        }
                        i -= 1
                    }
                }
            }
            return data
        }
}

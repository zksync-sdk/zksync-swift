//
//  Bits.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 11/01/2021.
//

import Foundation

enum BitsError: Error {
    case incorrectSize
}

struct Bits: CustomStringConvertible, Sequence, IteratorProtocol {
    
    private var currentIndex = 0
    mutating func next() -> Bool? {
        if currentIndex < self.bits.count {
            currentIndex += 1
            return bits[currentIndex - 1]
        } else {
            currentIndex = 0
            return nil
        }
    }
    
    typealias Element = Bool
    
    private var bits: [Bool]

    init(size: Int) {
        self.bits = Array<Bool>(repeating: false, count: size)
    }
    
    init(bits: [Bool]) {
        self.bits = bits
    }
    
    init(dataBEOrder: Data) {
        self.init(size: dataBEOrder.count * 8)
        dataBEOrder.enumerated().forEach { (index, byte) in
            for i in 0...7 {
                bits[index * 8 + i] = (((byte >> (7 - i)) & 0x01) == 1)
            }
        }
    }
    
    var size: Int {
        return bits.count
    }
    
    subscript(index: Int) -> Bool {
        get {
            return bits[index]
        }
        set(newValue) {
            bits[index] = newValue
        }
    }

    mutating func set(index: Int) {
        bits[index] = true
    }
    
    mutating func set(index: Int, value: Int) {
        bits[index] = value != 0
    }

    var reversed: Bits {
        return Bits(bits: bits.reversed())
    }

    var description: String {
        return bits.reduce("") { (result, bit) -> String in
            var newResult = result.appending("\(bit ? 1 : 0)")
            newResult.append(", ")
            return newResult
        }
    }

    static func +(a: Bits, b: Bits) -> Bits {
        let size = a.size + b.size
        let aSize = a.size
        
        var bits = Bits(size: size)
        
        for (index, bit) in a.enumerated() {
            bits[index] = bit
        }
        
        for (index, bit) in b.enumerated() {
            bits[index + aSize] = bit
        }
        
        return bits
    }
    
    func bytesBEOrder() throws -> Data {
        
        guard bits.count % 8 == 0 else {
            throw BitsError.incorrectSize
        }
        
        let numBytes = bits.count / 8
        
        var resultBytes = Data(repeating: 0, count: numBytes)
        for currentByte in 0..<numBytes {
            var value = UInt8(0)
            
            if bits[currentByte * 8] {
                value |= 0x01
            }
            
            for bitIndex in 1..<8 {
                value <<= 1
                value |= bits[currentByte * 8 + bitIndex] ? 0x01 : 0x00
            }
            resultBytes[currentByte] = value
        }
        return resultBytes
    }
}

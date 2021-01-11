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
    
    func bytesBE() -> Data {
        return withUnsafeBytes(of: self) { Data($0.reversed()) }
    }
}

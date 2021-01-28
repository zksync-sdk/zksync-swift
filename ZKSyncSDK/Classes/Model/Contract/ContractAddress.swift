//
//  ContractAddress.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 06/01/2021.
//

import Foundation

public struct ContractAddress: Codable {
    public let mainContract: String
    public let govContract: String
}

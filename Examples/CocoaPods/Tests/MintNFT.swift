//
//  MintNFT.swift
//  ZKSyncExampleTests
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension MintNFT: Equatable {

    static var defaultTX: MintNFT {
        let mintNFT = MintNFT(creatorId: 44,
                              creatorAddress: "0xede35562d3555e61120a151b3c8e8e91d83a378a",
                              contentHash: "0x0000000000000000000000000000000000000000000000000000000000000123",
                              recipient: "0x19aa2ed8712072e918632259780e587698ef58df",
                              fee: "1000000",
                              feeToken: 0,
                              nonce: 12)
        mintNFT.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                      // swiftlint:disable:next line_length
                                      signature: "5cf4ef4680d58e23ede08cc2f8dd33123c339788721e307a813cdf82bc0bac1c10bc861c68d0b5328e4cb87b610e4dfdc13ddf8a444a4a2ac374ac3c73dbec05")
        return mintNFT
    }

    public static func == (lhs: MintNFT, rhs: MintNFT) -> Bool {
        return lhs.creatorId == rhs.creatorId &&
            lhs.creatorAddress == rhs.creatorAddress &&
            lhs.contentHash == rhs.contentHash &&
            lhs.recipient == rhs.recipient &&
            lhs.fee == rhs.fee &&
            lhs.feeToken == rhs.feeToken &&
            lhs.nonce == rhs.nonce &&
            lhs.signature?.pubKey == rhs.signature?.pubKey &&
            lhs.signature?.signature == rhs.signature?.signature
    }
}

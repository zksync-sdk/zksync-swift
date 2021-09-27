//
//  ChangePubKey.swift
//  ZKSyncExample
//
//  Created by Maxim Makhun on 9/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import ZKSync

extension ChangePubKey where T == ChangePubKeyCREATE2 {

    static var defaultTX: ChangePubKey<ChangePubKeyCREATE2> {
        let changePubKey = ChangePubKey<ChangePubKeyCREATE2>(accountId: 55,
                                                             account: "0x880296a3a63ef5a9a06d962cbd204b8b4a828203",
                                                             newPkHash: "sync:18e8446d7748f2de52b28345bdbc76160e6b35eb",
                                                             feeToken: 0,
                                                             fee: "1000000000",
                                                             nonce: 13,
                                                             timeRange: TimeRange(validFrom: 0, validUntil: 4294967295))
        changePubKey.signature = Signature(pubKey: "40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490",
                                           // swiftlint:disable:next line_length
                                           signature: "65b00a17484fd045907e4efc290c4231d19ef8402155156cf6fe85ecf6fa912e763d4210625c9ed79aa31d45f505bd2404ee40015c4e028a1bf03f81dda45b00")

        let creatorAddress = "0x" + [UInt8](repeating: 0, count: 40).toHexString()
        let salt = "0x" + [UInt8](repeating: 0, count: 64).toHexString()
        let codeHash = "0x" + [UInt8](repeating: 0, count: 64).toHexString()

        changePubKey.ethAuthData = ChangePubKeyCREATE2(creatorAddress: creatorAddress,
                                                       saltArg: salt,
                                                       codeHash: codeHash)

        return changePubKey
    }
}

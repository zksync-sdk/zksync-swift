//
//  ZkSignerTests.swift
//  ZKSyncSDK_Tests
//
//  Created by Eugene Belyakov on 20/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import ZKSync

class ZkSignerTests: XCTestCase {
    
    static let PrivateKey = "0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
    static let Seed = Data(hex: PrivateKey)
    static let Message = Data(hex: "0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f")
    static let PubKey = "0x17f3708f5e2b2c39c640def0cf0010fd9dd9219650e389114ea9da47f5874184"
    static let PubKeyHash = "sync:4f3015a1d2b93239f9510d8bc2cf49376a78a08e"
    static let PubKeyHashEth = "sync:18e8446d7748f2de52b28345bdbc76160e6b35eb"
    static let Signature = "5462c3083d92b832d540c9068eed0a0450520f6dd2e4ab169de1a46585b394a4292896a2ebca3c0378378963a6bc1710b64c573598e73de3a33d6cec2f5d7403"

    
    func testCreationFromSeed() throws {
        let signer = try ZkSigner(seed: ZkSignerTests.Seed)
        XCTAssertEqual(signer.publicKey.hexEncodedString().addHexPrefix().lowercased(),
                       ZkSignerTests.PubKey)
    }
    
    func testCreationFromEthSigner() throws {
        let ethSigner = try DefaultEthSigner(privateKey: ZkSignerTests.PrivateKey)
        let signer = try ZkSigner(ethSigner: ethSigner, chainId: .mainnet)
        XCTAssertEqual(signer.publicKeyHash, ZkSignerTests.PubKeyHashEth)
    }
    
    func testSigningMessage() throws {
        let signer = try ZkSigner(seed: ZkSignerTests.Seed)
        let signature = try signer.sign(message: ZkSignerTests.Message)
        XCTAssertEqual(signature.signature.lowercased(), ZkSignerTests.Signature)
    }

    func testPublicKeyHashGeneration() throws {
        let signer = try ZkSigner(seed: ZkSignerTests.Seed)
        XCTAssertEqual(signer.publicKeyHash,
                       ZkSignerTests.PubKeyHash)
    }
}

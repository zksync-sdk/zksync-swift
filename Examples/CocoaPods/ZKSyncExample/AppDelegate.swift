//
//  AppDelegate.swift
//  ZKSyncExample
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import UIKit
import ZKSync

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Verify whether public initializers are available.
        _ = ChangePubKeyCREATE2(creatorAddress: "", saltArg: "", codeHash: "")
        _ = ChangePubKeyOnchain()
        _ = ChangePubKeyECDSA(ethSignature: nil, batchHash: "")

        return true
    }
}

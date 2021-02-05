//
//  ZKSyncSDK.swift
//  ZKSyncSDK-UI
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

/**
* Access to the ZksCrypto native library
*
* This class provides methods for interaction the ZksCrypto native library.
*
*/
public class ZKCryptoSDK: NSObject {
    
    static public func generatePrivateKey(seed: Data) -> ZKCryptoSDKResult<ZKPrivateKey> {
        return seed.withUnsafeBytes { seedBufferRaw in
            let seedBuffer: UnsafePointer<UInt8> = seedBufferRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            let result = UnsafeMutablePointer<CLibZksPrivateKey>.allocate(capacity: 1)
            defer { result.deallocate() }
            
            let resultCode = zks_crypto_private_key_from_seed(seedBuffer, seed.count, result)
            
            switch resultCode {
            case PRIVATE_KEY_FROM_SEED_OK:
                let bufferPointer = [UInt8](UnsafeBufferPointer(start: &result[0].data.0, count: ZKPrivateKey.bytesLength))
                return .success(ZKPrivateKey(bufferPointer))
                
            case PRIVATE_KEY_FROM_SEED_SEED_TOO_SHORT:
                return .error(ZKCryptoSDKError.seedTooShortError)
                
            default:
                return .error(ZKCryptoSDKError.unsupportedOperation)
            }
        }
    }
    
    static public func getPublicKey(privateKey: ZKPrivateKey) -> ZKCryptoSDKResult<ZKPackedPublicKey> {
        return privateKey.withUnsafeBytes { bufferRaw in
            let privateKeyBuffer: UnsafePointer<UInt8> = bufferRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            
            let privateKeyObj = UnsafeMutablePointer<CLibZksPrivateKey>.allocate(capacity: 1)
            defer { privateKeyObj.deallocate() }
            
            withUnsafeMutablePointer(to: &privateKeyObj.pointee.data.0) { data in
                data.assign(from: privateKeyBuffer, count: ZKPrivateKey.bytesLength)
            }
            
            let result = UnsafeMutablePointer<CLibZksPackedPublicKey>.allocate(capacity: 1)
            defer { result.deallocate() }
            
            let resultCode = zks_crypto_private_key_to_public_key(privateKeyObj, result)
            
            switch resultCode {
            case PUBLIC_KEY_FROM_PRIVATE_OK:
                let bufferPointer = [UInt8](UnsafeBufferPointer(start: &result[0].data.0, count: ZKPackedPublicKey.bytesLength))
                return .success(ZKPackedPublicKey(bufferPointer))
                
            default:
                return .error(ZKCryptoSDKError.unsupportedOperation)
            }
        }
    }
    
    static public func getPublicKeyHash(publicKey: ZKPackedPublicKey) -> ZKCryptoSDKResult<ZKPublicHash> {
        return publicKey.withUnsafeBytes { bufferRaw in
            let publicKeyBuffer: UnsafePointer<UInt8> = bufferRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)

            let publicKeyObj = UnsafeMutablePointer<CLibZksPackedPublicKey>.allocate(capacity: 1)
            defer { publicKeyObj.deallocate() }
            
            withUnsafeMutablePointer(to: &publicKeyObj.pointee.data.0) { data in
                data.assign(from: publicKeyBuffer, count: ZKPackedPublicKey.bytesLength)
            }
            
            let result = UnsafeMutablePointer<CLibZksPubkeyHash>.allocate(capacity: 1)
            defer { result.deallocate() }

            let resultCode = zks_crypto_public_key_to_pubkey_hash(publicKeyObj, result)
            
            switch resultCode {
            case PUBKEY_HASH_FROM_PUBKEY_OK:
                let bufferPointer = [UInt8](UnsafeBufferPointer(start: &result[0].data.0, count: ZKPublicHash.bytesLength))
                return .success(ZKPublicHash(bufferPointer))

            default:
                return .error(ZKCryptoSDKError.unsupportedOperation)
            }
        }
    }
    
    static public func signMessage(privateKey: ZKPrivateKey, message: String) -> ZKCryptoSDKResult<ZKSignature> {
        guard let messageData = message.data(using: .utf8) else {
            return .error(ZKCryptoSDKError.unsupportedOperation)
        }
        
        return signMessage(privateKey: privateKey, message: messageData)
    }
    
    static public func signMessage(privateKey: ZKPrivateKey, message: Data) -> ZKCryptoSDKResult<ZKSignature> {
        return privateKey.withUnsafeBytes { bufferRaw in
            return message.withUnsafeBytes { messageRaw in
                let privateKeyBuffer: UnsafePointer<UInt8> = bufferRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
                let messageBuffer: UnsafePointer<UInt8> = messageRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
                
                let privateKeyObj = UnsafeMutablePointer<CLibZksPrivateKey>.allocate(capacity: 1)
                defer { privateKeyObj.deallocate() }
                
                withUnsafeMutablePointer(to: &privateKeyObj.pointee.data.0) { data in
                    data.assign(from: privateKeyBuffer, count: ZKPrivateKey.bytesLength)
                }
                
                let result = UnsafeMutablePointer<CLibZksSignature>.allocate(capacity: 1)
                defer { result.deallocate() }
                
                let resultCode = zks_crypto_sign_musig(privateKeyObj, messageBuffer, message.count, result)
                
                switch resultCode {
                case MUSIG_SIGN_OK:
                    let bufferPointer = [UInt8](UnsafeBufferPointer(start: &result[0].data.0, count: ZKSignature.bytesLength))
                    return .success(ZKSignature(bufferPointer))

                case MUSIG_SIGN_MSG_TOO_LONG:
                    return .error(ZKCryptoSDKError.musigTooLongError)
                    
                default:
                    return .error(ZKCryptoSDKError.unsupportedOperation)
                }
            }
        }
    }
    
}

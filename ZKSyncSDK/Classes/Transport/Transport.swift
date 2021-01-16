//
//  Transport.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

public typealias TransportResult<T> = Result<T, Error>

public protocol Transport {
    
    func send<Parameters: Encodable, Response: Decodable>(method: String,
                                                          params: Parameters?,
                                                          completion: @escaping (TransportResult<Response>) -> Void)

    func send<Parameters: Encodable, Response: Decodable>(method: String,
                                                          params: Parameters?,
                                                          queue: DispatchQueue,
                                                          completion: @escaping (TransportResult<Response>) -> Void)
}

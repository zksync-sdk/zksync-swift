//
//  HTTPTransport.swift
//  ZKSyncSDK
//
//  Created by Eugene Belyakov on 04/01/2021.
//

import Foundation
import Alamofire
import BigInt

public class HTTPTransport: Transport {
    
    private let networkURL: URL
    private var session: Session
    
    public init(networkURL: URL) {
        self.networkURL = networkURL
        let configuration = URLSessionConfiguration.default
        var headers = configuration.httpAdditionalHeaders ?? [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        configuration.httpAdditionalHeaders = headers
        self.session = Session(configuration: configuration)
    }
    
    public convenience init(network: Network)  {
        self.init(networkURL: network.url)
    }
    
    public func send<P, R>(method: String,
                           params: P?,
                           completion: @escaping (TransportResult<R>) -> Void) where P : Encodable, R : Decodable {
        self.send(method: method,
                  params: params,
                  queue: .main,
                  completion: completion)
    }

    
    public func send<P, R>(method: String,
                           params: P?,
                           queue: DispatchQueue,
                           completion: @escaping (TransportResult<R>) -> Void) where P : Encodable, R : Decodable {
        
        self.session.request(self.networkURL,
                             method: .post,
                             parameters: JRPCRequest(method: method, params: params),
                             encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(queue: queue, decoder: JRPCDecoder()) { [weak self] (response: DataResponse<R, AFError>) in
                switch response.result {
                case .success(let result):
                    completion(.success(result))
                case .failure(let afError):
                    print(afError)
                    break
                }
            }
    }
    
    private func jsonData<P: Encodable>(for method: String, parameters: P?) throws -> Data {
        
        let jrpcRequest = JRPCRequest(method: method, params: parameters)
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(jrpcRequest)
        } catch {
            throw ZKSyncError.malformedRequest
        }
    }
}

class JRPCDecoder: DataDecoder {
    func decode<D>(_ type: D.Type, from data: Data) throws -> D where D : Decodable {
        let decoder = JSONDecoder()
        
        let response = try decoder.decode(JRPCResponse<D>.self, from: data)
        guard let result = response.result else {
            guard let error = response.error else {
                throw ZKSyncError.malformedResponse
            }
            throw ZKSyncError.rpcError(code: error.code, message: error.message)
        }
        return result
    }
}

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
                guard let self = self else { return }
                completion(response.result.mapError{ self.processAFError($0) })
                //Can be used for debug
//                switch response.result {
//                case .success(let result):
//                    completion(.success(result))
//                case .failure(let afError):
//                    let error = self.processAFError(afError)
//                    completion(.failure(error))
//                    break
//                }
            }
    }
    
    private func processAFError(_ afError: AFError) -> Error {
        if case let AFError.responseSerializationFailed(reason) = afError {
            switch reason {
            case .customSerializationFailed(let error),
                 .decodingFailed(let error),
                 .jsonSerializationFailed(let error):
                return error
            default:
                return afError
            }
        } else if case let AFError.responseValidationFailed(reason) = afError,
                  case let .unacceptableStatusCode(code) = reason {
            return ZKSyncError.invalidStatusCode(code: code)
        } else if case let AFError.sessionTaskFailed(error: taskError) = afError {
            return taskError
        }
        
        return afError
    }
}

class JRPCDecoder: DataDecoder {
    func decode<D>(_ type: D.Type, from data: Data) throws -> D where D : Decodable {
        let decoder = JSONDecoder()
        
        let response = try decoder.decode(JRPCResponse<D>.self, from: data)
        
        guard let result = response.result else {
            guard let error = response.error else {
                throw ZKSyncError.emptyResponse
            }
            throw ZKSyncError.rpcError(code: error.code, message: error.message)
        }
        return result
    }
}

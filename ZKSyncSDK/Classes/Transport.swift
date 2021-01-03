//
//  Transport.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

struct Counter {
    static var counter = UInt64(1)
    static var lockQueue = DispatchQueue(label: "counterQueue")
    static func increment() -> UInt64 {
        var nextValue: UInt64 = 0
        lockQueue.sync {
            nextValue = Counter.counter
            Counter.counter = Counter.counter + 1
        }
        
        return nextValue
    }
}

struct JRPCError: Codable {
    public let code: Int
    public let message: String
}

struct JRPCRequest<T: Codable>: Codable {
    /// The rpc id
    public let id: UInt64 = Counter.increment()

    /// The jsonrpc version. Typically 2.0
    public let jsonrpc: String = "2.0"

    /// The jsonrpc method to be called
    public let method: String

    /// The jsonrpc parameters
    public let params: T?
}

struct JRPCResponse<T: Codable>: Codable {
    /// The rpc id
    public let id: Int

    /// The jsonrpc version. Typically 2.0
    public let jsonrpc: String

    /// The result
    public let result: T?

    /// The error
    public let error: JRPCError?
}


class JRPCTransport {
    var network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func request<Request: Codable, Response: Codable>(method: String,
                                                      params: Request?,
                                                      completion: @escaping (Result<Response, ZKSyncError>) -> Void)  {
        
        let requst = JRPCRequest(method: method, params: params)
        
        guard let jsonData = try? JSONEncoder().encode(requst) else {
            completion(.failure(ZKSyncError.malformedRequest))
            return
        }

        let url = URL(string: self.network.address)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            guard let response = try? JSONDecoder().decode(JRPCResponse<Response>.self, from: data) else {
                completion(.failure(ZKSyncError.malformedResponse))
                return
            }
            
            if let error = response.error {
                completion(.failure(ZKSyncError.rpcError(code: error.code, message: error.message)))
                return
            }

            if let data = response.result {
                completion(.success(data))
                return
            }
        }
        
        task.resume()
    }
    
}

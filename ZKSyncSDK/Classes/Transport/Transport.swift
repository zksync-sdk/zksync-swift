//
//  Transport.swift
//  ZKSyncSDK
//
//  Made with ❤️ by Matter Labs on 10/23/20
//

import Foundation

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

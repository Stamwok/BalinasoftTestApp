//
//  WebClient.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation
import Alamofire
import Combine

final class WebClient<T: Decodable> {
    
    private let baseURL = "https://junior.balinasoft.com"
    
    func request(path: String, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default) -> AnyPublisher<T, Error> {
        return AF.request(baseURL+path, method: method, parameters: parameters, encoding: encoding)
            .validate { (request, response, data) -> DataRequest.ValidationResult in
                if let request = request,
                   let body = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                    debugPrint("Request: \(request)")
                    debugPrint("Body: \(body)")
                    
                }
                debugPrint(response)
                debugPrint(String(data: data ?? Data(), encoding: .utf8) ?? "")
                return .success(())
            }
            .publishData()
            .tryMap { output in
                guard let httpResponse = output.response, httpResponse.statusCode == 200 else {
                    throw BaseServiceError.badRequest
                }
                if let result = output.data.flatMap({ try? JSONDecoder().decode(T.self, from: $0) }) {
                    return result
                } else {
                    throw BaseServiceError.decodableError
                }
            }.eraseToAnyPublisher()
    }
}

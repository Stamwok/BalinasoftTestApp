//
//  ServiceImpl.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation
import Combine
import Alamofire

final class ServiceImpl: Service {
    func postPhoto(input: PostPhotoInput) -> AnyPublisher<PostPhotoResponse, Error> {
        return WebClient<PostPhotoResponse>().request(path: "/api/v2/photo", method: .post, parameters: DictionaryEncoder.encode(input), encoding: JSONEncoding.default)
    }
    
    func getPhotoTypesList() -> AnyPublisher<PhotoTypesListResponse, Error> {
        return WebClient<PhotoTypesListResponse>().request(path: "/api/v2/photo/type")
    }
}

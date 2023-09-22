//
//  Service.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation
import Combine

protocol Service {
    func postPhoto(input: PostPhotoInput) -> AnyPublisher<PostPhotoResponse, Error>
    func getPhotoTypesList() -> AnyPublisher<PhotoTypesListResponse, Error>
}

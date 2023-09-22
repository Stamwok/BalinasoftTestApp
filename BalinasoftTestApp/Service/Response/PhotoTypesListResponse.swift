//
//  PhotoTypesListResponse.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation

struct PhotoTypesListResponse: Decodable {
    
    var content: PhotoDTO?
    var page: Int?
    var pageSize: Int?
    var totalElements: Int?
    var totalPages: Int?
}

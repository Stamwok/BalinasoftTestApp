//
//  PostPhotoInput.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation

struct PostPhotoInput: Encodable {
    
    var name: String
    var photo: Data
    var typeId: Int
}

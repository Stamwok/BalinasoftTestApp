//
//  DictionaryEncoder.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation
import Alamofire

class DictionaryEncoder {
    
    private init() {}

    static func encode<T>(_ value: T) -> Parameters where T : Encodable {
        guard let data = try? JSONEncoder().encode(value) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Parameters ?? [:]) ?? [:]
    }
}

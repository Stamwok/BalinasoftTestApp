//
//  BaseServiceError.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation

enum BaseServiceError: Error {
    case badRequest
    case decodableError
}

extension BaseServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "BadRequest"
        case .decodableError:
            return "DecodableError"
        }
    }
}

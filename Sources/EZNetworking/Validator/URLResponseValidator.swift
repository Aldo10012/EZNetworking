//
//  File.swift
//  
//
//  Created by Alberto Dominguez on 6/19/24.
//

import Foundation

public protocol URLResponseValidator {
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws
}

public struct URLResponseValidatorImpl: URLResponseValidator {
    public init() {}

    public func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws {
        guard data != nil else {
            throw NetworkingError.noData
        }
        guard let urlResponse else {
            throw NetworkingError.noResponse
        }
        if let error = error {
            throw NetworkingError.requestFailed(error)
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.noHTTPURLResponse
        }
        
        let errorResponse = httpURLResponse.networkingError
        if case .ok = errorResponse {
            return
        } else {
            throw errorResponse
        }
    }
}

//
//  File.swift
//  
//
//  Created by Alberto Dominguez on 6/19/24.
//

import Foundation

public protocol URLResponseValidator {
    func validate(_ response: URLResponse, withData data: Data) throws
}

public struct URLResponseValidatorImpl: URLResponseValidator {
    public init() {}
    
    public func validate(_ response: URLResponse, withData data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkingError.noHTTPURLResponse
        }
        
        let errorResponse = httpResponse.networkingError
        if case .ok = errorResponse {
            return
        } else {
            throw errorResponse
        }
    }
}

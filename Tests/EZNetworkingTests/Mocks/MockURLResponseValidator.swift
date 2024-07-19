//
//  File.swift
//  
//
//  Created by Alberto Dominguez on 7/18/24.
//

import Foundation
import EZNetworking

struct MockURLResponseValidator: URLResponseValidator {
    var throwError: NetworkingError?
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws {
        guard let throwError else {
            return
        }
        throw throwError
    }
}

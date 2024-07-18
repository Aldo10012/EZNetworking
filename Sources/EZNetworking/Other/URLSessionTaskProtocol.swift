//
//  File.swift
//  
//
//  Created by Alberto Dominguez on 7/17/24.
//

import Foundation

public protocol URLSessionTaskProtocol {
    func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionTaskProtocol {}

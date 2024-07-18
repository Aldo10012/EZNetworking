//
//  File.swift
//  
//
//  Created by Alberto Dominguez on 7/17/24.
//

import Foundation

public enum VoidResult<T: Error> {
    case success
    case failure(T)
}

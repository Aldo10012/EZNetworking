//
//  File.swift
//  
//
//  Created by Alberto Dominguez on 7/15/24.
//

import Foundation

let mockPersonJsonData = """
{
    "name": "John",
    "age": 30
}
""".data(using: .utf8)!

let invalidMockPersonJsonData = """
{
    "Name": "John",
    "Age": 30
}
""".data(using: .utf8)!

import Foundation

let mockPersonJsonData: Data = """
{
    "name": "John",
    "age": 30
}
""".data(using: .utf8)!

let invalidMockPersonJsonData: Data = """
{
    "Name": "John",
    "Age": 30
}
""".data(using: .utf8)!

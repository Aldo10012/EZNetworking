import Foundation
@testable import EZNetworking

struct MockData {
    static var mockPersonJsonData: Data {
        let jsonString = """
        {
            "name": "John",
            "age": 30
        }
        """
        return HTTPBody.jsonString(jsonString).data!
    }
    
    static var invalidMockPersonJsonData: Data {
        let jsonString = """
        {
            "Name": "John",
            "Age": 30
        }
        """
        return HTTPBody.jsonString(jsonString).data!
    }
}

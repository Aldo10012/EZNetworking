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
        return Data(jsonString: jsonString)!
    }

    static var invalidMockPersonJsonData: Data {
        let jsonString = """
        {
            "Name": "John",
            "Age": 30
        }
        """
        return Data(jsonString: jsonString)!
    }

    static func imageUrlData(from imageUrlString: String) -> Data? {
        guard let url = URL(string: imageUrlString) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            return nil
        }
    }
}

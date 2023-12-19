import Foundation

public enum HttpMethod: String {
    case get
    case post
    case put
    case delete

    var value: String {
        self.rawValue.uppercased()
    }
}

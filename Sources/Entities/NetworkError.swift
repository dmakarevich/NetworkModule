import Foundation

public enum NetworkError: Error {
    case noData
    case badURL
    case badRequest
    case parsingError
    case parsing(Error)
    case requestError
    case serverError
    case custom(String)
}

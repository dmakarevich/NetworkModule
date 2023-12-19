import Foundation

public protocol BaseTargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HttpMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: String]? { get }
    var data: Data? { get }
}

// MARK: - Exapmle of usage

enum SamleNetworkRequest {
    case allItems
    case createNewItem
}

extension SamleNetworkRequest: BaseTargetType {
    var baseURL: URL {
        return URL(string: "https://many-items.com")!
    }
    
    var path: String {
        switch self {
        case .allItems:
            return "/items/all"
        case .createNewItem:
            return "/items/new"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .allItems:
            return .get
        case .createNewItem:
            return .post
        }
    }

    var headers: [String : String]? {
        return nil
    }

    var parameters: [String : String]? {
        return nil
    }

    var data: Data? {
        return nil
    }
}

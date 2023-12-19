import Foundation

public protocol RequestInterceptor {
    func intercept(request: inout URLRequest)
}

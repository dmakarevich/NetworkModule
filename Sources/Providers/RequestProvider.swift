import Foundation

public protocol RequestProviderType: AnyObject {
    associatedtype API: BaseTargetType

    func request<T: Decodable>(_ endpoint: API, completion: @escaping ([T]?, NetworkError?) -> Void)
    func request<T: Decodable>(_ endpoint: API, completion: @escaping (T?, NetworkError?) -> Void)
    func cancel()
}

public class RequestProvider<API: BaseTargetType>: RequestProviderType {
    private var additionalParameters: [String: String]?
    private var customHeaders: [String: String]?
    private var requestInterceptor: RequestInterceptor?
    private var task: URLSessionDataTask?

    public init(requestInterceptor: RequestInterceptor? = nil) {
        self.requestInterceptor = requestInterceptor
    }

    public func request<T: Decodable>(_ endpoint: API, completion: @escaping (T?, NetworkError?) -> Void) {
        guard var request = buildRequest(for: endpoint) else {
            completion(nil, .badURL)
            return
        }

        applyInterceptor(urlRequest: &request)

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, error == nil, let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestError)
                return
            }

            switch self.handleResponseResult(httpResponse) {
            case .success:
                guard let receivedData = data else {
                    completion(nil, .noData)
                    return
                }
                do {
                    let model = try JSONDecoder().decode(T.self, from: receivedData)
                    completion(model, nil)
                } catch let parsingError {
                    completion(nil, .parsing(parsingError))
                }
            case .failure(let networkError):
                completion(nil, networkError)
            }
        }
        task?.resume()
    }

    public func request<T: Decodable>(_ endpoint: API, completion: @escaping ([T]?, NetworkError?) -> Void) {
        guard var request = buildRequest(for: endpoint) else {
            completion(nil, .badURL)
            return
        }

        applyInterceptor(urlRequest: &request)

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, error == nil, let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestError)
                return
            }

            switch self.handleResponseResult(httpResponse) {
            case .success:
                guard let receivedData = data else {
                    completion(nil, .noData)
                    return
                }
                do {
                    let models = try JSONDecoder().decode([T].self, from: receivedData)
                    completion(models, nil)
                } catch let parsingError {
                    completion(nil, .parsing(parsingError))
                }
            case .failure(let networkError):
                completion(nil, networkError)
            }
        }
        task?.resume()
    }

    public func cancel() {
        task?.cancel()
    }

    // MARK: Setters

    public func setCustomHeaders(_ headers: [String: String]) -> Self {
        customHeaders = headers
        return self
    }

    public func setAdditionalParameters(_ parameters: [String: String]) -> Self {
        additionalParameters = parameters
        return self
    }
}

// MARK: Utility

private extension RequestProvider {
    func buildRequest(for endpoint: API) -> URLRequest? {
        guard let url = prepareURL(for: endpoint) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.value
        request.httpBody = endpoint.data

        endpoint.headers?.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        customHeaders?.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    func prepareURL(for endpoint: API) -> URL? {
        guard let url = URL(string: endpoint.path, relativeTo: endpoint.baseURL),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) 
        else {
            return nil
        }

        components.queryItems = []
        if let parameters = endpoint.parameters {
            parameters.forEach { key, value in
                components.queryItems?.append(.init(name: key, value: value))
            }
        }
        if let parameters = additionalParameters {
            parameters.forEach { key, value in
                components.queryItems?.append(.init(name: key, value: value))
            }
        }

        guard let url = components.url else {
            return nil
        }

        return url
    }

    func applyInterceptor(urlRequest: inout URLRequest) {
        if let interceptor = requestInterceptor {
            interceptor.intercept(request: &urlRequest)
        }
    }

    func handleResponseResult(_ response: HTTPURLResponse) -> ResponseResult {
        switch response.statusCode {
        case 200...299:
            return .success
        case 401...500:
            return .failure(.badRequest)
        case 501...599:
            return .failure(.serverError)
        default:
            return .failure(.requestError)
        }
    }
}

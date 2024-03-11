import Foundation

private enum NetworkError: Error {
    case badEndpoint
    case invalidResponse
    case retryLimitReached
    case invalidStatusCode(_ statusCode: Int)
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class Networking {
    private static let maxRetryAttempts = 3
    
    class func fetchData(
        from urlString: String,
        httpMethod: HttpMethod = .get,
        body: Data? = nil,
        headers: [String: String]? = nil,
        retryCount: Int = 0
    ) async throws -> Data {
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.badEndpoint
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        if let body, httpMethod != .get {
            request.httpBody = body
        }
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidStatusCode((response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            
            return data
            
        } catch {
            if retryCount < maxRetryAttempts {
                return try await fetchData(
                    from: urlString,
                    httpMethod: httpMethod,
                    body: body,
                    headers: headers,
                    retryCount: retryCount + 1
                )
            } else {
                throw NetworkError.retryLimitReached
            }
        }
    }
    
    class func request<T: Decodable>(
        from urlString: String,
        type: T.Type,
        httpMethod: HttpMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        let data = try await fetchData(
            from: urlString,
            httpMethod: httpMethod,
            body: body,
            headers: headers)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error unable to decode data from \(String(describing: String(data: data, encoding: .utf8))). Error: \(error.localizedDescription)")
            throw error
        }
    }
}

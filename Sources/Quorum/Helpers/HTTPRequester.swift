import Foundation
import LGNCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class HTTPRequester {
    public enum Method: String {
        case GET, POST, PUT
    }

    public enum ContentType: String {
        case JSON = "application/json"
        case URLEncoded = "application/x-www-form-urlencoded"

        public func encode(params: Any) -> Data? {
            switch self {
            case .URLEncoded:
                guard let params = params as? [String: String] else {
                    return nil
                }
                return params
                    .map { key, value in "\(key)=\(value)" }
                    .joined(separator: "&")
                    .data(using: .utf8)
            case .JSON:
                return try? JSONSerialization.data(withJSONObject: params)
            }
        }
    }

    public enum E: Error {
        case InvalidURL
    }

    public static func requestJSON(
        method: Method = .POST,
        url: String,
        params: Any? = nil,
        headers: [String: String] = [:]
    ) async throws -> (Data?, URLResponse?) {
        try await self.request(
            method: method,
            contentType: .JSON,
            url: url,
            params: params,
            headers: headers
        )
    }

    public static func request(
        method: Method,
        contentType: ContentType,
        url urlString: String,
        params: Any? = nil,
        headers: [String: String] = [:]
    ) async throws -> (Data?, URLResponse?) {
        guard let url = URL(string: urlString) else {
            throw E.InvalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue

        if let params = params {
            request.httpBody = contentType.encode(params: params)
        }

        headers.forEach { key, value in request.addValue(value, forHTTPHeaderField: key)}

        return try await withUnsafeThrowingContinuation { continuation in
            URLSession.shared
                .dataTask(with: request) {
                    if let error = $2 {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ($0, $1))
                    }
                }
                .resume()
        }
    }
}

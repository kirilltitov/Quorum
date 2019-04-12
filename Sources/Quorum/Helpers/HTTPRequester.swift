import Foundation
import LGNCore
import NIO

public class HTTPRequester {
    public enum Method: String {
        case GET, POST
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
        headers: [String: String] = [:],
        on eventLoop: EventLoop
    ) -> Future<(Data?, URLResponse?, Error?)> {
        return self.request(
            method: method,
            contentType: .JSON,
            url: url,
            params: params,
            headers: headers,
            on: eventLoop
        )
    }

    public static func request(
        method: Method,
        contentType: ContentType,
        url urlString: String,
        params: Any? = nil,
        headers: [String: String] = [:],
        on eventLoop: EventLoop
    ) -> Future<(Data?, URLResponse?, Error?)> {
        let promise: Promise<(Data?, URLResponse?, Error?)> = eventLoop.makePromise()

        guard let url = URL(string: urlString) else {
            promise.fail(E.InvalidURL)
            return promise.futureResult
        }

        var request = URLRequest(url: url)
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue

        if let params = params {
            request.httpBody = contentType.encode(params: params)
        }

        headers.forEach { key, value in request.addValue(value, forHTTPHeaderField: key)}

        URLSession.shared
            .dataTask(with: request) { promise.succeed(($0, $1, $2)) }
            .resume()

        return promise.futureResult
    }
}

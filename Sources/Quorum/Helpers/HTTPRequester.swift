import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1

public enum HTTPRequester {
    public enum Method: String {
        case GET, POST, PUT
    }

    /// Maximum size of a response body
    static let maxResponseSize = 1024 * 1024

    /// Performs a JSON request, returns response body and status code
    public static func requestJSON(
        method: Method = .POST,
        url: String,
        params: Any? = nil,
        headers: [String: String] = [:],
        timeout: TimeAmount = .seconds(10)
    ) async throws -> (Data, Int) {
        var request = HTTPClientRequest(url: url)
        request.method = HTTPMethod(rawValue: method.rawValue)
        request.headers.add(name: "Content-Type", value: "application/json")
        for (key, value) in headers {
            request.headers.add(name: key, value: value)
        }
        if let params {
            request.body = .bytes(ByteBuffer(bytes: try JSONSerialization.data(withJSONObject: params)))
        }

        let response = try await HTTPClient.shared.execute(request, timeout: timeout)
        let body = try await response.body.collect(upTo: self.maxResponseSize)

        return (Data(body.readableBytesView), Int(response.status.code))
    }
}

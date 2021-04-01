import Foundation
import LGNCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

func registerToConsul() async throws {
    do {
        let tags: [String] = ["main"]
        let fullServiceName = "\(SERVICE_ID)-\(PORTAL_ID.lowercased())"
        let params: [String: Any] = [
            "ID": "main-\(fullServiceName)",
            "Name": fullServiceName,
            "Address": "\(config[.PRIVATE_IP])",
            "Port": LGNS_PORT,
            "Tags": tags,
            "Checks": [
                [
                    "Name": "LGNS",
                    "Interval": 5,
                    "TCP": "\(config[.PRIVATE_IP]):\(config[.LGNS_PORT])"
                ],
            ],
        ]
        defaultLogger.info(
            "Registering in consul with payload '\(try! JSONSerialization.data(withJSONObject: params)._string)'"
        )
        let (maybeData, maybeResponse) = try await HTTPRequester.requestJSON(
            method: .PUT,
            url: "http://consul:8500/v1/agent/service/register",
            params: params
        )

        guard let response = maybeResponse as? HTTPURLResponse else {
            throw E.Consul("No response")
        }

        guard
            let data = maybeData,
            let json = String(data: data, encoding: .ascii)
        else {
            throw E.Consul("No JSON")
        }

        guard response.statusCode == 200 else {
            throw E.Consul("Non-200 status code: \(response.statusCode), JSON: '\(json)'")
        }

        defaultLogger.info("Successfully registered in Consul")
    } catch {
        defaultLogger.critical("Could not register to consul: \(error)")
        fatalError()
    }
}

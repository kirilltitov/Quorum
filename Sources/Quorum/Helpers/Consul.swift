import Foundation
import LGNCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

func registerToConsul() async throws {
    do {
        let tags: [String] = ["main"]
        let fullServiceName = "\(App.SERVICE_ID)-\(App.current.PORTAL_ID.lowercased())"
        let params: [String: Any] = [
            "ID": "main-\(fullServiceName)",
            "Name": fullServiceName,
            "Address": "\(App.current.config[.PRIVATE_IP])",
            "Port": App.current.LGNS_PORT,
            "Tags": tags,
            "Checks": [
                [
                    "Name": "LGNS",
                    "Interval": 5,
                    "TCP": "\(App.current.config[.PRIVATE_IP]):\(App.current.config[.LGNS_PORT])"
                ],
            ],
        ]
        App.current.defaultLogger.info(
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

        App.current.defaultLogger.info("Successfully registered in Consul")
    } catch {
        App.current.defaultLogger.critical("Could not register to consul: \(error)")
        fatalError()
    }
}

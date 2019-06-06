import Foundation
import LGNCore

func registerToConsul() throws {
    do {
        let tags: [String] = ["main"]
        let params: [String: Any] = [
            "Name": "\(SERVICE_ID.lowercased())-\(PORTAL_ID.lowercased())",
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
            "Registering in consul with payload '\(try! JSONSerialization.data(withJSONObject: params).bytes._string)'"
        )
        let (maybeData, maybeResponse, maybeError) = try HTTPRequester.requestJSON(
            method: .PUT,
            url: "http://consul:8500/v1/agent/service/register",
            params: params,
            on: eventLoopGroup.eventLoop
        ).wait()

        if let error = maybeError {
            throw error
        }

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

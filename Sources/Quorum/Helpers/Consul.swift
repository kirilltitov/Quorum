import Foundation
import LGNCore
import LGNLog
import LGNConfig


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
        Logger.current.info(
            "Registering in consul with payload '\(try! JSONSerialization.data(withJSONObject: params)._string)'"
        )
        let (data, statusCode) = try await HTTPRequester.requestJSON(
            method: .PUT,
            url: "http://consul:8500/v1/agent/service/register",
            params: params
        )

        guard statusCode == 200 else {
            throw E.Consul("Non-200 status code: \(statusCode), response: '\(data._string)'")
        }

        Logger.current.info("Successfully registered in Consul")
    } catch {
        Logger.current.critical("Could not register to consul: \(error)")
        fatalError()
    }
}

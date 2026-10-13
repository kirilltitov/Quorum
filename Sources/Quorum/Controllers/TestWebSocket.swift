import Foundation
import Generated
import LGNCore
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.TestWebSocket

public class TestWebSocketController {
    public static func setup() {
        Contract.guarantee { (request) async throws -> Contract.Response in
            return Contract.Response(
                string_output: "got '\(request.string_input)'",
                int_output: 1711_000 + request.int_input
            )
        }
    }
}

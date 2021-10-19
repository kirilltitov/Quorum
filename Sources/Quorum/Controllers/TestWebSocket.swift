import Foundation
import Generated
import LGNCore
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.TestWebSocket

public class TestWebSocketController {
    public static func setup() {
        Contract.guarantee { (request) async throws -> Contract.Response in
            if let currentUser = Models.User.current {
                dump(currentUser)
            }
            return Contract.Response(
                string_output: "got '\(request.string_input)'",
                int_output: 1711_000 + request.int_input
            )
        }
    }
}

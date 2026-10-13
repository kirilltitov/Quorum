import LGNCore
import LGNC
import Generated

/// Returns user info
public enum UserInfoController {
    typealias Contract = Services.Quorum.Contracts.UserInfo

    public static func setup() {
        Contract.guarantee { (request: Contract.Request) async throws -> Contract.Response in
            guard let user = try await Logic.User.get(by: request.IDUser) else {
                throw LGNC.ContractError.GeneralError("User with given ID not found", 404)
            }
            return Contract.Response(accessLevel: user.accessLevel.rawValue)
        }
    }
}

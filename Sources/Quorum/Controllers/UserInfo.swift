import LGNCore
import LGNC
import Generated

/// Returns user info
public enum UserInfoController {
    typealias Contract = Services.Quorum.Contracts.UserInfo

    public static func setup() {
        Contract.guarantee { (request: Contract.Request, context: LGNCore.Context) -> EventLoopFuture<Contract.Response> in
            Logic.User
                .get(by: request.IDUser, context: context)
                .mapThrowing { maybeUser in
                    guard let user = maybeUser else {
                        throw LGNC.ContractError.GeneralError("User with given ID not found", 404)
                    }

                    return Contract.Response(accessLevel: user.accessLevel.rawValue)
                }
        }
    }
}

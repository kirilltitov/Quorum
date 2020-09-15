import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

/// Sets user accessLevel in Quorum and in Author
public struct UpdateUserAccessLevelController {
    typealias Contract = Services.Quorum.Contracts.UpdateUserAccessLevel

    public static func setup() {
        Contract.guarantee { (request: Contract.Request, context: LGNCore.Context) -> EventLoopFuture<Contract.Response> in
            Logic.User
                .authenticate(token: request.token, context: context)
                .flatMapThrowing { (currentUser: Models.User) -> Void in
                    guard currentUser.accessLevel == .Admin else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    guard currentUser.ID.string != request.IDUser else {
                        throw LGNC.ContractError.GeneralError("Can't change own access level", 405)
                    }
                }
                .flatMap {
                    Logic.User.get(by: request.IDUser, context: context)
                }
                .flatMapThrowing { (maybeUser: Models.User?) throws -> (Models.User, Models.User.AccessLevel) in
                    guard let user = maybeUser else {
                        throw LGNC.ContractError.GeneralError("User '\(request.IDUser)' not found", 404)
                    }
                    guard let accessLevel = Models.User.AccessLevel(rawValue: request.accessLevel) else {
                        throw LGNC.ContractError.GeneralError("Invalid access level '\(request.accessLevel)'", 400)
                    }
                    return (user, accessLevel)
                }
                .flatMap { (user: Models.User, accessLevel: Models.User.AccessLevel) -> EventLoopFuture<Void> in
                    user.set(accessLevel: accessLevel, on: context.eventLoop)
                }
                .map { empty }
        }
    }
}

import Foundation
import Generated
import LGNCore
import LGNS
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.UpdateUserAccessLevel

extension Contract.Request: AnyEntityWithSession {}

/// Sets user accessLevel in Quorum and in Author
public struct UpdateUserAccessLevelController {
    public static func setup() {
        Contract.guarantee { (request: Contract.Request) -> Contract.Response in
            let currentUser = try await Logic.User.authenticate(request: request)
            guard currentUser.accessLevel == .Admin else {
                throw LGNC.ContractError.GeneralError("Not authorized", 403)
            }
            guard currentUser.ID.string != request.IDUser else {
                throw LGNC.ContractError.GeneralError("Can't change own access level", 405)
            }

            let maybeUser = try await Logic.User.get(by: request.IDUser)
            guard let user = maybeUser else {
                throw LGNC.ContractError.GeneralError("User '\(request.IDUser)' not found", 404)
            }
            guard let accessLevel = Models.User.AccessLevel(rawValue: request.accessLevel) else {
                throw LGNC.ContractError.GeneralError("Invalid access level '\(request.accessLevel)'", 400)
            }

            try await user.set(accessLevel: accessLevel)

            return App.empty
        }
    }
}

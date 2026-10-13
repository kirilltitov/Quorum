import Generated
import LGNCore
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.UndeleteComment

extension Contract.Request: AnyEntityWithSession {}

/// Moves comment from `deleted` status to `published` status
class UndeleteController {
    static func setup() {
        func contractRoutine(request: Contract.Request) async throws -> Contract.Response {
            let user = try await Logic.User.authenticate(request: request)
            guard user.isAtLeastModerator else {
                throw LGNCore.Context.current.errorNotAuthenticated
            }

            return try await Logic.Comment.undelete(ID: request.IDComment).getContractComment()
        }

        Contract.guarantee(contractRoutine)
    }
}

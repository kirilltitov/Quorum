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
                throw Task.local(\.context).errorNotAuthenticated
            }

            let comment = try await Logic.Comment.getThrowing(by: request.IDComment)
            guard comment.status == .deleted else {
                throw LGNC.ContractError.GeneralError("Cannot undelete comment from non-deleted status", 401)
            }

            try await Logic.Comment.undelete(comment: comment)

            return try await comment.getContractComment()
        }

        Contract.guarantee(contractRoutine)
    }
}

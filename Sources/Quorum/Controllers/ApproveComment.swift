import LGNCore
import Generated
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.ApproveComment

extension Contract.Request: AnyEntityWithSession {}

/// Moves comment from `pending` status to `published` status (premoderation)
public struct ApproveCommentController {
    public static func setup() {
        func contractRoutine(request: Contract.Request) async throws -> Contract.Response {
            let user = try await Logic.User.authenticate(request: request)
            guard user.accessLevel == .Admin || user.accessLevel == .Moderator else {
                throw LGNCore.Context.current.errorNotAuthenticated
            }

            return try await Logic.Comment.approve(ID: request.IDComment).getContractComment()
        }

        Contract.guarantee(contractRoutine)
    }
}

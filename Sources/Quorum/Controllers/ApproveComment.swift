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

            let comment = try await Logic.Comment.getThrowing(by: request.IDComment)
            try await Logic.Comment.approve(comment: comment)
            return try await comment.getContractComment()
        }

        Contract.guarantee(contractRoutine)
    }
}

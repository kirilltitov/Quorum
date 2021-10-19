import LGNCore
import Generated
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.RejectComment

extension Contract.Request: AnyEntityWithSession {}

/// Rejects and DELETES the comment from storage (rejected premoderation)
public struct RejectCommentController {
    public static func setup() {
        func contractRoutine(request: Contract.Request) async throws -> Contract.Response {
            let user = try await Logic.User.authenticate(request: request)
            guard user.accessLevel == .Admin || user.accessLevel == .Moderator else {
                throw LGNCore.Context.current.errorNotAuthenticated
            }

            try await Logic.Comment.reject(comment: try await Logic.Comment.getThrowing(by: request.IDComment))

            return Contract.Response()
        }

        Contract.guarantee(contractRoutine)
    }
}

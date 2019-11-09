import LGNCore
import Generated
import LGNC

/// Rejects and DELETES the comment from storage (rejected premoderation)
public struct RejectCommentController {
    typealias Contract = Services.Quorum.Contracts.RejectComment

    public static func setup() {
        func contractRoutine(
            request: Contract.Request,
            context: LGNCore.Context
        ) -> Future<Contract.Response> {
            let eventLoop = context.eventLoop
            return Logic.User
                .authenticate(token: request.token, context: context)
                .mapThrowing { user in
                    guard user.accessLevel == .Admin || user.accessLevel == .Moderator else {
                        throw context.errorNotAuthenticated
                    }
                    return
                }
                .flatMap { Logic.Comment.getThrowing(by: request.IDComment, on: eventLoop) }
                .flatMap { comment in Logic.Comment.reject(comment: comment, on: eventLoop) }
                .map { _ in Contract.Response() }
        }

        Contract.guarantee(contractRoutine)
    }
}

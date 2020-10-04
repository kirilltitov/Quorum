import LGNCore
import Generated
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.RejectComment

extension Contract.Request: AnyEntityWithSession {}

/// Rejects and DELETES the comment from storage (rejected premoderation)
public struct RejectCommentController {
    public static func setup() {
        func contractRoutine(
            request: Contract.Request,
            context: LGNCore.Context
        ) -> EventLoopFuture<Contract.Response> {
            let eventLoop = context.eventLoop
            return Logic.User
                .authenticate(request: request, context: context)
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

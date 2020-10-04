import LGNCore
import Generated
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.ApproveComment

extension Contract.Request: AnyEntityWithSession {}

/// Moves comment from `pending` status to `published` status (premoderation)
public struct ApproveCommentController {
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
                .flatMap { comment in Logic.Comment.approve(comment: comment, on: eventLoop) }
                .flatMap { comment in comment.getContractComment(context: context)}
        }

        Contract.guarantee(contractRoutine)
    }
}

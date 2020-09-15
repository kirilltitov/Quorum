import LGNCore
import Generated
import LGNC

/// Moves comment from `pending` status to `published` status (premoderation)
public struct ApproveCommentController {
    typealias Contact = Services.Quorum.Contracts.ApproveComment

    public static func setup() {
        func contractRoutine(
            request: Contact.Request,
            context: LGNCore.Context
        ) -> EventLoopFuture<Contact.Response> {
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
                .flatMap { comment in Logic.Comment.approve(comment: comment, on: eventLoop) }
                .flatMap { comment in comment.getContractComment(context: context)}
        }

        Contact.guarantee(contractRoutine)
    }
}

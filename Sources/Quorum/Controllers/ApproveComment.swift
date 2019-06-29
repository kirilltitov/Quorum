import LGNCore
import Generated
import LGNC

/// Moves comment from `pending` status to `published` status (premoderation)
public struct ApproveCommentController {
    typealias Contact = Services.Quorum.Contracts.ApproveComment

    public static func setup() {
        func contractRoutine(
            request: Contact.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contact.Response> {
            let eventLoop = info.eventLoop

            return Logic.User
                .authenticate(token: request.token, requestInfo: info)
                .mapThrowing { user in
                    guard user.accessLevel == .Admin || user.accessLevel == .Moderator else {
                        throw LGNC.ContractError.GeneralError("Not authenticated", 403)
                    }
                    return
                }
                .flatMap { Logic.Comment.getThrowing(by: request.IDComment, on: eventLoop) }
                .flatMap { comment in Logic.Comment.approve(comment: comment, on: eventLoop) }
                .flatMap { comment in comment.getContractComment(requestInfo: info)}
        }

        Contact.guarantee(contractRoutine)
    }
}

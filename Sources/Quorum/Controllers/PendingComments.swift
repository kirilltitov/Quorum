import Generated
import LGNCore
import LGNC

class UnapprovedCommentsController {
    public static func setup() {
        typealias CommentsContract = Services.Quorum.Contracts.PendingComments

        func contractRoutine(
            request: CommentsContract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<CommentsContract.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .mapThrowing { user in
                    guard user.isAtLeastModerator else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    return
                }
                .flatMap { Models.PendingComment.getUnapprovedComments(on: eventLoop) }
                .flatMap { comments in
                    Future<[Services.Shared.Comment]>.reduce(
                        into: [],
                        comments.map { comment in comment.getContractComment(on: eventLoop) },
                        on: eventLoop
                    ) { $0.append($1) }
                }
                .map { CommentsContract.Response(comments: $0) }
        }

        CommentsContract.guarantee(contractRoutine)
    }
}

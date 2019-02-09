import Generated
import LGNCore
import LGNC

class UnapprovedCommentsController {
    public static func setup() {
        typealias CommentsContract = Services.Quorum.Contracts.UnapprovedComments

        func contractRoutine(
            request: CommentsContract.Request,
            info: LGNC.RequestInfo
        ) -> Future<CommentsContract.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .thenThrowing { user in
                    guard user.isAtLeastModerator else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    return ()
                }
                .then { Models.UnapprovedComment.getUnapprovedComments(on: eventLoop) }
                .then { comments in
                    Future<[Services.Shared.Comment]>.reduce(
                        into: [],
                        comments.map { comment in
                            let user = comment.getUser(on: eventLoop)
                            return Services.Shared.Comment.await(
                                ID: comment.ID,
                                IDUser: user.map { $0.ID.string },
                                userName: user.map { $0.username },
                                IDPost: comment.IDPost,
                                IDReplyComment: comment.IDReplyComment,
                                isDeleted: comment.isDeleted,
                                isApproved: false,
                                body: comment.body,
                                likes: eventLoop.newSucceededFuture(result: 0),
                                dateCreated: comment.dateCreated.formatted,
                                dateUpdated: comment.dateUpdated.formatted
                            )
                        },
                        eventLoop: eventLoop
                    ) { $0.append($1) }
                }
                .map { CommentsContract.Response(comments: $0) }
        }

        CommentsContract.guarantee(contractRoutine)
    }
}

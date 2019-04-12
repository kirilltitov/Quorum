import LGNCore
import Generated
import LGNC

public struct ApproveCommentController {
    typealias Contact = Services.Quorum.Contracts.ApproveComment

    public static func setup() {
        func contractRoutine(
            request: Contact.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contact.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .mapThrowing { user in
                    guard user.accessLevel == .Admin || user.accessLevel == .Moderator else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    return ()
                }
                .flatMap { Logic.Comment.getThrowing(by: request.IDComment, on: eventLoop) }
                .flatMap { comment in Logic.Comment.approve(comment: comment, on: eventLoop) }
                .flatMap { comment in
                    let user = comment.getUser(on: eventLoop)
                    return Contact.Response.await(
                        ID: comment.ID,
                        IDUser: user.map { $0.ID.string },
                        userName: user.map { $0.username },
                        IDPost: comment.IDPost,
                        IDReplyComment: comment.IDReplyComment,
                        status: comment.status.rawValue,
                        body: comment.body,
                        likes: Models.Like.getLikesFor(comment: comment, on: eventLoop),
                        dateCreated: comment.dateCreated.formatted,
                        dateUpdated: comment.dateUpdated.formatted
                    )
                }
        }

        Contact.guarantee(contractRoutine)
    }
}

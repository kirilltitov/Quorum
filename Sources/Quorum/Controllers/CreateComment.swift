import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

public struct CreateController {
    typealias Contract = Services.Quorum.Contracts.CreateComment

    public static func setup() {
        Contract.Request.validateIdpost { ID, eventLoop in
            Logic.Post
                .get(by: ID, snapshot: true, on: eventLoop)
                .map { post in
                    guard let post = post else {
                        return .PostNotFound
                    }
                    guard post.isCommentable else {
                        return .PostIsReadOnly
                    }
                    return nil
                }
        }

        Contract.Request.validateIdreplycomment { ID, eventLoop in
            Logic.Comment
                .doExists(ID: ID, on: eventLoop)
                .map {
                    guard $0 == true else {
                        return .ReplyingCommentNotFound
                    }
                    return nil
                }
        }

        Contract.guarantee { (request: Contract.Request, info: LGNC.RequestInfo) -> Future<Contract.Response> in
            let eventLoop = info.eventLoop
            let user = Logic.User.authorize(token: request.token, on: eventLoop)

            return Models.Comment.await(
                on: eventLoop,
                ID: Models.Comment.getNextID(on: eventLoop),
                IDUser: user.map(\.ID),
                IDPost: request.IDPost,
                IDReplyComment: request.IDReplyComment,
                body: Logic.Comment.getProcessedBody(from: request.body)
            )
            .then { comment in user.map { (comment, $0) } }
            .then { comment, user in Logic.Comment.insert(comment: comment, as: user, on: eventLoop) }
            .then { comment in
                Contract.Response.await(
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
    }
}

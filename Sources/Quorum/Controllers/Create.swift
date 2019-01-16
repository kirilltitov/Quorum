import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

typealias CreateContract = Services.Quorum.Contracts.Create

public struct CreateController {
    public static func setup() {
        CreateContract.Request.validateIdpost { ID, eventLoop in
            return Logic.Post
                .get(by: ID, on: eventLoop)
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

        CreateContract.Request.validateToken { token, eventLoop in
            return Logic.User
                .authorize(token: token, on: eventLoop)
                .map { _ in nil }
        }

        CreateContract.Request.validateIdreplycomment { ID, eventLoop in
            return Logic.Comment
                .doExists(ID: ID, on: eventLoop)
                .map {
                    guard $0 == true else {
                        return .ReplyingCommentNotFound
                    }
                    return nil
                }
        }

        CreateContract.guarantee { (request: CreateContract.Request, info: LGNC.RequestInfo) -> Future<CreateContract.Response> in
            let eventLoop = info.eventLoop
            let user = Logic.User.authorize(token: request.token, on: eventLoop)

            return Models.Comment.await(
                on: eventLoop,
                ID: Models.Comment.getNextID(on: eventLoop),
                IDUser: user.map { $0.ID },
                IDPost: request.IDPost,
                IDReplyComment: request.IDReplyComment,
                isDeleted: false,
                body: Logic.Comment.getProcessedBody(from: request.body),
                dateCreated: Date(),
                dateUpdated: Date.distantPast
            )
            .then { comment in Logic.Comment.insert(comment: comment, on: eventLoop) }
            .then { comment in
                CreateContract.Response.await(
                    on: eventLoop,
                    ID: comment.ID,
                    IDUser: user.map { $0.ID.string },
                    userName: user.map { $0.username },
                    IDPost: comment.IDPost,
                    IDReplyComment: comment.IDReplyComment,
                    isDeleted: comment.isDeleted,
                    body: comment.body,
                    likes: Models.Like.getLikesFor(comment: comment, on: eventLoop),
                    dateCreated: comment.dateCreated.formatted,
                    dateUpdated: comment.dateUpdated.formatted
                )
            }
        }
    }
}

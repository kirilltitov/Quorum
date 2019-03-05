import Foundation
import Generated
import LGNCore
import LGNC
import LGNS
import Entita2
import NIO

public struct CommentsController {
    typealias Contract = Services.Quorum.Contracts.Comments

    public static func setup() {
        Contract.Request.validateIdpost { ID, eventLoop in
            return Logic.Post
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

        Contract.guarantee { (
            request: Contract.Request,
            info: LGNC.RequestInfo
        ) -> Future<Contract.Response> in
            let eventLoop = info.eventLoop
            return Logic.User
                .maybeAuthorize(token: request.token, on: eventLoop)
                .then { maybeUser in Logic.Post.getCommentsFor(ID: request.IDPost, as: maybeUser, on: eventLoop) }
                .flatMap { commentsWithLikes in
                    EventLoopFuture<[Models.User.Identifier: Models.User]>.reduce(
                        into: [:],
                        Set(commentsWithLikes.map { $0.comment.IDUser }).map {
                            Logic.User.get(by: $0, on: eventLoop)
                        },
                        eventLoop: eventLoop,
                        { users, _user in
                            let user = _user ?? Models.User.unknown
                            users[user.ID] = user
                        }
                    ).map { users -> (
                            [Logic.Post.CommentWithLikes],
                            [Models.User.Identifier: Models.User]
                        ) in (commentsWithLikes, users)
                    }
                }
                .map { commentsWithLikes, users -> Contract.Response in
                    Contract.Response(
                        comments: commentsWithLikes.map { commentWithLikes in
                            let comment = commentWithLikes.comment
                            return .init(
                                ID: comment.ID,
                                IDUser: comment.IDUser.string,
                                userName: (users[comment.IDUser] ?? Models.User.unknown).username,
                                IDPost: comment.IDPost,
                                IDReplyComment: comment.IDReplyComment,
                                isDeleted: comment.isDeleted,
                                isApproved: comment.isApproved,
                                body: comment.body,
                                likes: commentWithLikes.likes,
                                dateCreated: comment.dateCreated.formatted,
                                dateUpdated: comment.dateUpdated.formatted
                            )
                        }
                    )
                }
        }
    }
}

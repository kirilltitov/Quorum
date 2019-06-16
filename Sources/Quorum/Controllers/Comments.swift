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
        Contract.guarantee { (
            request: Contract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> in
            let eventLoop = info.eventLoop

            return Logic.User
                .maybeAuthorize(token: request.token, on: eventLoop)
                .flatMap { maybeUser in
                    Logic.Post.getCommentsFor(ID: request.IDPost, as: maybeUser, on: eventLoop)
                }
                .flatMap {
                    (commentsWithLikes: [Logic.Post.CommentWithLikes])
                    -> Future<([Logic.Post.CommentWithLikes], [Models.User.Identifier: Models.User])> in
                    EventLoopFuture<[Models.User.Identifier: Models.User]>.reduce(
                        into: [:],
                        Set(commentsWithLikes.map { $0.comment.IDUser }).map { Logic.User.get(by: $0, on: eventLoop) },
                        on: eventLoop,
                        { users, _user in
                            let user = _user ?? Models.User.unknown
                            users[user.ID] = user
                        }
                    ).map { users in (commentsWithLikes, users) }
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
                                isEditable: comment.isEditable,
                                status: comment.status.rawValue,
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

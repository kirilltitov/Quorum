import Foundation
import Generated
import LGNCore
import LGNC
import LGNS
import Entita2
import NIO

public struct CommentsController {
    typealias Contract = Services.Quorum.Contracts.Comments
    typealias CommentsWithLikesAndUsers = ([Logic.Post.CommentWithLikes], [Models.User.Identifier: Models.User])

    public static func setup() {
        Contract.guarantee { (
            request: Contract.Request,
            context: LGNCore.Context
        ) -> EventLoopFuture<Contract.Response> in
            let eventLoop = context.eventLoop

            return Logic.User
                .maybeAuthenticate(token: request.token, context: context)
                .flatMap { maybeUser in Logic.Post.getCommentsFor(ID: request.IDPost, as: maybeUser, on: eventLoop) }
                .flatMap { (commentsWithLikes: [Logic.Post.CommentWithLikes]) -> EventLoopFuture<CommentsWithLikesAndUsers> in
                    EventLoopFuture<[Models.User.Identifier: Models.User]>.reduce(
                        into: [:],
                        Set(
                            commentsWithLikes.map { $0.comment.IDUser }
                        ).map { Logic.User.get(by: $0, context: context) },
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
                            let user = users[comment.IDUser] ?? Models.User.unknown

                            return .init(
                                ID: comment.ID,
                                user: Services.Shared.CommentUserInfo(
                                    ID: comment.IDUser.string,
                                    username: user.username,
                                    accessLevel: user.accessLevel.rawValue
                                ),
                                IDPost: comment.IDPostEncoded,
                                IDReplyComment: comment.IDReplyComment,
                                isEditable: comment.isEditable,
                                status: comment.status.rawValue,
                                body: comment.body,
                                likes: commentWithLikes.likes,
                                dateCreated: comment.dateCreated.contractFormatted(locale: context.locale),
                                dateUpdated: comment.dateUpdated.contractFormatted(locale: context.locale)
                            )
                        }
                    )
                }
        }
    }
}

import Foundation
import Generated
import LGNCore
import LGNC
import LGNS
import Entita2
import NIO

public struct CommentsController {
    typealias ListContract = Services.Quorum.Contracts.Comments

    public static func setup() {
        ListContract.Request.validateIdpost { ID, eventLoop in
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

        ListContract.guarantee { (
            request: ListContract.Request,
            info: LGNC.RequestInfo
        ) -> Future<ListContract.Response> in
            return Logic.Post
                .getCommentsFor(ID: request.IDPost, on: info.eventLoop)
                .then { commentsWithLikes in
                    EventLoopFuture<[Models.User.Identifier: Models.User]>.reduce(
                        into: [:],
                        Set(commentsWithLikes.map { $0.value.comment.IDUser }).map {
                            Logic.User.get(by: $0, on: info.eventLoop)
                        },
                        eventLoop: info.eventLoop,
                        { users, _user in
                            let user = _user ?? Models.User.unknown
                            users[user.ID] = user
                        }
                    ).map { users -> (
                            [Models.Comment.Identifier: Logic.Post.CommentWithLikes],
                            [Models.User.Identifier: Models.User]
                        ) in (commentsWithLikes, users)
                    }
                }
                .map { commentsWithLikes, users -> ListContract.Response in
                    ListContract.Response(
                        comments: commentsWithLikes.map { commentWithLikes in
                            let comment = commentWithLikes.value.comment
                            return .init(
                                ID: comment.ID,
                                IDUser: comment.IDUser.string,
                                userName: (users[comment.IDUser] ?? Models.User.unknown).username,
                                IDPost: comment.IDPost,
                                IDReplyComment: comment.IDReplyComment,
                                isDeleted: comment.isDeleted,
                                body: comment.body,
                                likes: commentWithLikes.value.likes,
                                dateCreated: comment.dateCreated.formatted,
                                dateUpdated: comment.dateUpdated.formatted
                            )
                        }
                    )
                }
        }
    }
}

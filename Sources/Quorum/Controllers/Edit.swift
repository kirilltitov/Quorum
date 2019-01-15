import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

public struct EditController {
    typealias EditContract = Services.Quorum.Contracts.Edit

    public static func setup() {
        EditContract.Request.validateIdpost { ID, eventLoop in
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

        EditContract.Request.validateIdcomment { ID, eventLoop in
            Logic.Comment
                .get(by: ID, on: eventLoop)
                .map {
                    guard let comment: Models.Comment = $0 else {
                        return .CommentNotFound
                    }
                    guard comment.dateCreated.timeIntervalSince < COMMENT_EDITABLE_TIME else {
                        return .ThisCommentIsNotEditableAnymore
                    }
                    return nil
                }
        }

        EditContract.Request.validateToken { token, eventLoop in
            return Logic.User
                .authorize(token: token, on: eventLoop)
                .map { _ in nil }
        }

        EditContract.guarantee { (request: EditContract.Request, info: LGNC.RequestInfo) -> Future<EditContract.Response> in
            return Logic.User
                .authorize(token: request.token, on: info.eventLoop)
                .then { (user: Models.User) -> Future<(Models.Comment, Models.User)> in
                    Logic.Comment
                        .get(by: request.IDComment, on: info.eventLoop)
                        .thenThrowing {
                            guard let comment = $0 else {
                                throw LGNC.ContractError.GeneralError("Comment still not found (how is this possible?)", 1711)
                            }
//                            guard user.ID == comment.IDUser else {
//                                throw LGNC.ContractError.GeneralError("It's not your comment", 403)
//                            }
                            return (comment, user)
                        }
                }
                .then { (comment, user) -> Future<(Models.Comment, Models.User)> in
                    comment.body = Logic.Comment.getProcessedBody(from: request.body)
                    comment.dateUpdated = Date()
                    return Logic.Comment
                        .save(comment: comment, on: info.eventLoop)
                        .map { ($0, user) }
                }
                .then { (comment, user) in
                    Models.Like.getLikesFor(comment: comment, user: user, on: info.eventLoop)
                }
                .map { tuple in
                    let (comment, likes, user) = tuple
                    return EditContract.Response(
                        ID: comment.ID,
                        IDUser: comment.IDUser.string,
                        userName: user.username,
                        IDPost: comment.IDPost,
                        IDReplyComment: comment.IDReplyComment,
                        isDeleted: comment.isDeleted,
                        body: comment.body,
                        likes: likes,
                        dateCreated: comment.dateCreated.formatted,
                        dateUpdated: comment.dateUpdated.formatted
                    )
                }
        }
    }
}

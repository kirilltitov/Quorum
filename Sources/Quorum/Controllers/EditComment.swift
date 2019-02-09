import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2FDB

public struct EditController {
    typealias Contract = Services.Quorum.Contracts.EditComment

    public static func setup() {
        Contract.Request.validateIdcomment { ID, eventLoop in
            Logic.Comment
                .get(by: ID, on: eventLoop)
                .map {
                    guard let _: Models.Comment = $0 else {
                        return .CommentNotFound
                    }
                    return nil
                }
        }
        
        func contractRoutine(
            request: Contract.Request,
            info: LGNC.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop
            
            let userFuture = Logic.User.authorize(token: request.token, on: eventLoop)
            
            return userFuture
                .flatMap { (user: Models.User) -> Future<(Models.Comment, Transaction)> in
                    Logic.Comment
                        .getThrowingWithTransaction(by: request.IDComment, on: eventLoop)
                        .then { (comment, transaction) in
                            Logic.Post
                                .getThrowing(by: comment.IDPost, on: eventLoop)
                                .map { post in (post, comment, transaction) }
                        }
                        .thenThrowing { post, comment, transaction in
                            if user.isAtLeastModerator {
                                return (comment, transaction)
                            }
                            guard post.isCommentable else {
                                throw LGNC.ContractError.GeneralError("Comment is not aditable anymore", 403)
                            }
                            guard comment.isApproved else {
                                throw LGNC.ContractError.GeneralError("Comment is not approved yet", 403)
                            }
                            guard user.ID == comment.IDUser else {
                                throw LGNC.ContractError.GeneralError("It's not your comment", 403)
                            }
                            guard comment.dateCreated.timeIntervalSince < COMMENT_EDITABLE_TIME else {
                                throw LGNC.ContractError.GeneralError("This comment is not editable anymore", 408)
                            }
                            guard comment.dateUpdated.timeIntervalSince > COMMENT_EDIT_COOLDOWN else {
                                throw LGNC.ContractError.GeneralError("You're editing too often", 429)
                            }
                            return (comment, transaction)
                    }
                }
                .flatMap { comment, transaction in
                    Logic.Comment.edit(
                        comment: comment,
                        body: request.body,
                        with: transaction,
                        on: eventLoop
                    )
                }
                .flatMap { comment in
                    Contract.Response.await(
                        ID: comment.ID,
                        IDUser: userFuture.map { $0.ID.string },
                        userName: userFuture.map { $0.username },
                        IDPost: comment.IDPost,
                        IDReplyComment: comment.IDReplyComment,
                        isDeleted: comment.isDeleted,
                        isApproved: comment.isApproved,
                        body: comment.body,
                        likes: Models.Like.getLikesFor(comment: comment, on: eventLoop),
                        dateCreated: comment.dateCreated.formatted,
                        dateUpdated: comment.dateUpdated.formatted
                    )
                }
                .flatMapIfErrorThrowing { error in
                    if case FDB.Error.TransactionRetry = error {
                        return contractRoutine(request: request, info: info)
                    }
                    throw error
                }
        }

        Contract.guarantee(contractRoutine)
    }
}

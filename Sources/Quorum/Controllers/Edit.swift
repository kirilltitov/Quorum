import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2FDB

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
                    guard let _: Models.Comment = $0 else {
                        return .CommentNotFound
                    }
                    return nil
                }
        }
        
        func contractRoutine(
            request: EditContract.Request,
            info: LGNC.RequestInfo
        ) -> Future<EditContract.Response> {
            let eventLoop = info.eventLoop
            
            let userFuture = Logic.User.authorize(token: request.token, on: eventLoop)
            
            return userFuture
                .flatMap { (user: Models.User) -> Future<(Models.Comment, Transaction)> in
                    Logic.Comment
                        .getThrowingWithTransaction(by: request.IDComment, on: eventLoop)
                        .thenThrowing { comment, transaction in
                            if user.isAdmin == true {
                                return (comment, transaction)
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
                    EditContract.Response.await(
                        on: eventLoop,
                        ID: comment.ID,
                        IDUser: userFuture.map { $0.ID.string },
                        userName: userFuture.map { $0.username },
                        IDPost: comment.IDPost,
                        IDReplyComment: comment.IDReplyComment,
                        isDeleted: comment.isDeleted,
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

        EditContract.guarantee(contractRoutine)
    }
}

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
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop
            
            let userFuture = Logic.User.authenticate(token: request.token, requestInfo: info)
            
            return userFuture
                .flatMap { (user: Models.User) -> Future<(Models.Comment, FDB.Transaction)> in
                    Logic.Comment
                        .getThrowingWithTransaction(by: request.IDComment, on: eventLoop)
                        .flatMap { (comment, transaction) in
                            Logic.Post
                                .getPostStatus(comment.IDPost, on: eventLoop)
                                .map { status in (status, comment, transaction) }
                        }
                        .mapThrowing { status, comment, transaction in
                            if user.isAtLeastModerator {
                                return (comment, transaction)
                            }

                            guard status != .NotCommentable else {
                                throw LGNC.ContractError.GeneralError("Comment is not editable anymore", 403)
                            }

                            guard user.ID == comment.IDUser else {
                                throw LGNC.ContractError.GeneralError("It's not your comment", 403)
                            }

                            guard comment.isEditable else {
                                throw LGNC.ContractError.GeneralError("This comment is not editable anymore", 408)
                            }

                            let editDiff = Date().timeIntervalSince1970 - comment.dateUpdated.timeIntervalSince1970
                            guard editDiff > COMMENT_EDIT_COOLDOWN else {
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
                .flatMap { comment in comment.getContractComment(requestInfo: info) }
                .flatMapIfErrorThrowing { error in
                    if case FDB.Error.transactionRetry = error {
                        return contractRoutine(request: request, info: info)
                    }
                    throw error
                }
        }

        Contract.guarantee(contractRoutine)
    }
}

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
            
            return Logic.User
                .authenticate(token: request.token, requestInfo: info)
                .flatMap { (user: Models.User) -> Future<(Models.Comment, Models.User, FDB.Transaction)> in
                    Logic.Comment
                        .getThrowingWithTransaction(by: request.IDComment, on: eventLoop)
                        .flatMap { (comment, transaction) in
                            Logic.Post
                                .getPostStatus(comment.IDPost, on: eventLoop)
                                .map { status in (status, comment, transaction) }
                        }
                        .mapThrowing { status, comment, transaction in
                            if user.isAtLeastModerator {
                                return (comment, user, transaction)
                            }

                            guard status != .NotCommentable else {
                                throw LGNC.ContractError.GeneralError(
                                    "Comment is not editable anymore".tr(info.locale),
                                    403
                                )
                            }

                            guard user.ID == comment.IDUser else {
                                throw LGNC.ContractError.GeneralError(
                                    "It's not your comment".tr(info.locale),
                                    403
                                )
                            }

                            guard comment.isEditable else {
                                throw LGNC.ContractError.GeneralError(
                                    "This comment is not editable anymore".tr(info.locale),
                                    408
                                )
                            }

                            let editDiff = Date().timeIntervalSince1970 - comment.dateUpdated.timeIntervalSince1970
                            guard editDiff > COMMENT_EDIT_COOLDOWN_SECONDS else {
                                throw LGNC.ContractError.GeneralError(
                                    "You're editing too often".tr(info.locale),
                                    429
                                )
                            }

                            return (comment, user, transaction)
                    }
                }
                .flatMap { comment, user, transaction in
                    Logic.Comment.edit(
                        comment: comment,
                        body: request.body,
                        by: user,
                        within: transaction,
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

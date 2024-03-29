import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2FDB

fileprivate typealias Contract = Services.Quorum.Contracts.EditComment

extension Contract.Request: AnyEntityWithSession {}

public struct EditController {
    public static func setup() {
        Contract.Request.validateIDComment { ID, eventLoop in
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
            context: LGNCore.Context
        ) -> EventLoopFuture<Contract.Response> {
            let eventLoop = context.eventLoop
            
            return Logic.User
                .authenticate(request: request, context: context)
                .flatMap { (user: Models.User) -> EventLoopFuture<(Models.Comment, Models.User, AnyFDBTransaction)> in
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
                                    "Comment is not editable anymore".tr(context.locale),
                                    403
                                )
                            }

                            guard user.ID == comment.IDUser else {
                                throw LGNC.ContractError.GeneralError(
                                    "It's not your comment".tr(context.locale),
                                    403
                                )
                            }

                            guard comment.isEditable else {
                                throw LGNC.ContractError.GeneralError(
                                    "This comment is not editable anymore".tr(context.locale),
                                    408
                                )
                            }

                            let editDiff = Date().timeIntervalSince1970 - comment.dateUpdated.timeIntervalSince1970
                            guard editDiff > COMMENT_EDIT_COOLDOWN_SECONDS else {
                                throw LGNC.ContractError.GeneralError(
                                    "You're editing too often".tr(context.locale),
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
                .flatMap { comment in comment.getContractComment(context: context) }
                .flatMapIfErrorThrowing { error in
                    if case FDB.Error.transactionRetry = error {
                        return contractRoutine(request: request, context: context)
                    }
                    throw error
                }
        }

        Contract.guarantee(contractRoutine)
    }
}

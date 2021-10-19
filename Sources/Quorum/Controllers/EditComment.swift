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
        Contract.Request.validateIDComment { ID in
            guard try await Logic.Comment.get(by: ID) != nil else {
                return .CommentNotFound
            }
            return nil
        }
        
        func contractRoutine(request: Contract.Request) async throws -> Contract.Response {
            let user = try await Logic.User.authenticate(request: request)

            return try await App.current.fdb
                .withTransaction { (transaction: AnyFDBTransaction) async throws -> Models.Comment in
                    let comment = try await Logic.Comment.getThrowing(by: request.IDComment, within: transaction)

                    if !user.isAtLeastModerator {
                        guard await Logic.Post.getPostStatus(comment.IDPost) != .NotCommentable else {
                            throw LGNC.ContractError.GeneralError("Comment is not editable anymore".tr(), 403)
                        }

                        guard user.ID == comment.IDUser else {
                            throw LGNC.ContractError.GeneralError("It's not your comment".tr(), 403)
                        }

                        guard comment.isEditable else {
                            throw LGNC.ContractError.GeneralError("This comment is not editable anymore".tr(), 408)
                        }

                        let editDiff = Date().timeIntervalSince1970 - comment.dateUpdated.timeIntervalSince1970
                        guard editDiff > App.COMMENT_EDIT_COOLDOWN_SECONDS else {
                            throw LGNC.ContractError.GeneralError("You're editing too often".tr(), 429)
                        }
                    }

                    try await Logic.Comment.edit(
                        comment: comment,
                        body: request.body,
                        by: user,
                        within: transaction
                    )

                    try await transaction.commit()

                    return comment
                }
                .getContractComment()
        }

        Contract.guarantee(contractRoutine)
    }
}

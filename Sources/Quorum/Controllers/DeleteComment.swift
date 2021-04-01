import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

fileprivate typealias Contract = Services.Quorum.Contracts.DeleteComment

extension Contract.Request: AnyEntityWithSession {}

/// Moves comment from `published` status to `deleted` status (when displayed, body should be empty)
public struct DeleteController {
    public static func setup() {
        Contract.Request.validateIDComment { ID in
            guard try await Logic.Comment.get(by: ID) != nil else {
                return .CommentNotFound
            }
            return nil
        }

        Contract.guarantee { (request: Contract.Request) -> Contract.Response in
            let user = try await Logic.User.authenticate(request: request)
            let comment = try await Logic.Comment.getThrowing(by: request.IDComment)

            guard comment.IDUser == user.ID || user.isAtLeastModerator else {
                throw LGNC.ContractError.GeneralError("You have no authority to delete this comment", 403)
            }
            guard comment.status == .published else {
                throw LGNC.ContractError.GeneralError("Comment is not in deleteable status", 400)
            }

            try await Logic.Comment.delete(comment: comment)

            return empty
        }
    }
}

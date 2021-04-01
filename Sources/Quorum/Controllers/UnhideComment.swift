import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

fileprivate typealias Contract = Services.Quorum.Contracts.UnhideComment

extension Contract.Request: AnyEntityWithSession {}

/// Moves comment from `hidden` status to `published` status (restores the comment)
public struct UnhideController {
    public static func setup() {
        Contract.Request.validateIDComment { ID in
            guard try await Logic.Comment.get(by: ID) != nil else {
                return .CommentNotFound
            }
            return nil
        }

        Contract.guarantee { (request: Contract.Request) -> Contract.Response in
            let user = try await Logic.User.authenticate(request: request)
            guard user.isAtLeastModerator else {
                throw LGNC.ContractError.GeneralError("You have no authority to hide this comment", 403)
            }

            let comment = try await Logic.Comment.getThrowing(by: request.IDComment)
            guard comment.status == .hidden else {
                throw LGNC.ContractError.GeneralError("Comment is not in hideable status", 400)
            }

            try await Logic.Comment.unhide(comment: comment)

            return Contract.Response()
        }
    }
}

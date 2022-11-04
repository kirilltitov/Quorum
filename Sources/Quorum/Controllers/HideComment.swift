import Foundation
import Generated
import LGNCore
import LGNS
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.HideComment

extension Contract.Request: AnyEntityWithSession {}

/// Moves comment from `published` status to `hidden` status (hides the comment) from everyone except author and mods
public struct HideController {

    public static func setup() {
        Contract.Request.validateIDComment { ID in
            guard try await Logic.Comment.get(by: ID) != nil else {
                return .CommentNotFound
            }
            return nil
        }

        Contract.guarantee { (request: Contract.Request) async throws -> Contract.Response in
            let user = try await Logic.User.authenticate(request: request)
            let comment = try await Logic.Comment.getThrowing(by: request.IDComment)

            guard user.isAtLeastModerator else {
                throw LGNC.ContractError.GeneralError("You have no authority to hide this comment", 403)
            }
            guard comment.status == .published else {
                throw LGNC.ContractError.GeneralError("Comment is not in hideable status", 400)
            }

            try await Logic.Comment.hide(comment: comment)

            return Contract.Response()
        }
    }
}

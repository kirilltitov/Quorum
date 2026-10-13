import Foundation
import Generated
import LGNCore
import LGNS
import LGNC

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
            try await Logic.Comment.delete(ID: request.IDComment, by: user)

            return App.empty
        }
    }
}

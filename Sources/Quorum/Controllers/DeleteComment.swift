import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

/// Moves comment from `published` status to `deleted` status (like, when user is banned)
public struct DeleteController {
    typealias Contract = Services.Quorum.Contracts.DeleteComment

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

        Contract.guarantee { (request: Contract.Request, info: LGNCore.RequestInfo) -> Future<Contract.Response> in
            let eventLoop = info.eventLoop

            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .flatMap { user in
                    Logic.Comment
                        .getThrowing(by: request.IDComment, on: eventLoop)
                        .map { comment in (user, comment) }
                }
                .flatMapThrowing { (user: Models.User, comment: Models.Comment) throws -> Future<Void> in
                    guard comment.IDUser == user.ID || user.isAtLeastModerator else {
                        throw LGNC.ContractError.GeneralError("You have no authority to delete this comment", 403)
                    }
                    guard comment.status == .published else {
                        throw LGNC.ContractError.GeneralError("Comment is not in deleteable status", 400)
                    }
                    return Logic.Comment.delete(comment: comment, on: eventLoop)
                }
                .map { _ in Contract.Response() }
        }
    }
}

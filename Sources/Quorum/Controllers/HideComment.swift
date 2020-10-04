import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

fileprivate typealias Contract = Services.Quorum.Contracts.HideComment

extension Contract.Request: AnyEntityWithSession {}

/// Moves comment from `published` status to `hidden` status (hides the comment) from everyone except author and mods
public struct HideController {

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

        Contract.guarantee { (request: Contract.Request, context: LGNCore.Context) -> EventLoopFuture<Contract.Response> in
            let eventLoop = context.eventLoop

            return Logic.User
                .authenticate(request: request, context: context)
                .flatMap { user in
                    Logic.Comment
                        .getThrowing(by: request.IDComment, on: eventLoop)
                        .map { comment in (user, comment) }
                }
                .flatMapThrowing { (user: Models.User, comment: Models.Comment) throws -> EventLoopFuture<Void> in
                    guard user.isAtLeastModerator else {
                        throw LGNC.ContractError.GeneralError("You have no authority to hide this comment", 403)
                    }
                    guard comment.status == .published else {
                        throw LGNC.ContractError.GeneralError("Comment is not in hideable status", 400)
                    }
                    return Logic.Comment.hide(comment: comment, context: context)
                }
                .map { _ in Contract.Response() }
        }
    }
}

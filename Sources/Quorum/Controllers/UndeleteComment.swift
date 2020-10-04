import Generated
import LGNCore
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.UndeleteComment

extension Contract.Request: AnyEntityWithSession {}

/// Moves comment from `deleted` status to `published` status
class UndeleteController {
    static func setup() {
        func contractRoutine(
            request: Contract.Request,
            context: LGNCore.Context
        ) -> EventLoopFuture<Contract.Response> {
            let eventLoop = context.eventLoop

            return Logic.User
                .authenticate(request: request, context: context)
                .flatMap { user in
                    Logic.Comment
                        .getThrowing(by: request.IDComment, on: eventLoop)
                        .map { comment in (user, comment) }
                }
                .flatMapThrowing { (user: Models.User, comment: Models.Comment) throws -> EventLoopFuture<Models.Comment> in
                    guard user.isAtLeastModerator else {
                        throw context.errorNotAuthenticated
                    }
                    guard comment.status == .deleted else {
                        throw LGNC.ContractError.GeneralError(
                            "Cannot undelete comment from non-deleted status",
                            401
                        )
                    }
                    return Logic.Comment.undelete(comment: comment, on: eventLoop)
                }
                .flatMap { comment in comment.getContractComment(context: context) }
        }

        Contract.guarantee(contractRoutine)
    }
}

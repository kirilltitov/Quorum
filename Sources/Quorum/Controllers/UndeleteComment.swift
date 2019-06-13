import Generated
import LGNCore
import LGNC

/// Moves comment from `deleted` status to `published` status (when user is unbanned)
class UndeleteController {
    static func setup() {
        typealias Contract = Services.Quorum.Contracts.UndeleteComment

        func contractRoutine(
            request: Contract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .flatMap { user in
                    Logic.Comment
                        .getThrowing(by: request.IDComment, on: eventLoop)
                        .map { comment in (user, comment) }
                }
                .flatMapThrowing { (user: Models.User, comment: Models.Comment) throws -> Future<Void> in
                    guard user.isAtLeastModerator else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    guard comment.status == .deleted else {
                        throw LGNC.ContractError.GeneralError(
                            "Cannot undelete comment from non-deleted status",
                            401
                        )
                    }
                    return Logic.Comment.undelete(comment: comment, on: eventLoop)
                }
                .map { _ in .init() }
        }

        Contract.guarantee(contractRoutine)
    }
}

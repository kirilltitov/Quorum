import Generated
import LGNCore
import LGNC

/// Moves comment from `deleted` status to `published` status
class UndeleteController {
    static func setup() {
        typealias Contract = Services.Quorum.Contracts.UndeleteComment

        func contractRoutine(
            request: Contract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop

            return Logic.User
                .authenticate(token: request.token, requestInfo: info)
                .flatMap { user in
                    Logic.Comment
                        .getThrowing(by: request.IDComment, on: eventLoop)
                        .map { comment in (user, comment) }
                }
                .flatMapThrowing { (user: Models.User, comment: Models.Comment) throws -> Future<Models.Comment> in
                    guard user.isAtLeastModerator else {
                        throw info.errorNotAuthenticated
                    }
                    guard comment.status == .deleted else {
                        throw LGNC.ContractError.GeneralError(
                            "Cannot undelete comment from non-deleted status",
                            401
                        )
                    }
                    return Logic.Comment.undelete(comment: comment, on: eventLoop)
                }
                .flatMap { comment in comment.getContractComment(requestInfo: info) }
        }

        Contract.guarantee(contractRoutine)
    }
}

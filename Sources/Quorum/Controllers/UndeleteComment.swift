import Generated
import LGNCore
import LGNC

class UndeleteController {
    static func setup() {
        typealias Contract = Services.Quorum.Contracts.UndeleteComment

        func contractRoutine(
            request: Contract.Request,
            info: LGNC.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .flatMapThrowing { (user: Models.User) throws -> Future<Void> in
                    guard user.isAtLeastModerator else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    return Logic.Comment.undelete(commentID: request.IDComment, on: eventLoop)
                }
                .map { _ in Contract.Response() }
        }

        Contract.guarantee(contractRoutine)
    }
}

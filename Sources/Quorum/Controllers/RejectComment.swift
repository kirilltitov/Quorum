import LGNCore
import Generated
import LGNC

public struct RejectCommentController {
    typealias Contract = Services.Quorum.Contracts.Reject

    public static func setup() {
        func contractRoutine(
            request: Contract.Request,
            info: LGNC.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .thenThrowing { user in
                    guard user.accessLevel == .Admin || user.accessLevel == .Moderator else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    return ()
                }
                .then { Logic.Comment.getThrowing(by: request.IDComment, on: eventLoop) }
                .then { comment in Logic.Comment.reject(comment: comment, on: eventLoop) }
                .map { _ in Contract.Response() }
        }

        Contract.guarantee(contractRoutine)
    }
}

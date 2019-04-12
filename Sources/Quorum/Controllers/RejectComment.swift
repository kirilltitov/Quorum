import LGNCore
import Generated
import LGNC

public struct RejectCommentController {
    typealias Contract = Services.Quorum.Contracts.RejectComment

    public static func setup() {
        func contractRoutine(
            request: Contract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .mapThrowing { user in
                    guard user.accessLevel == .Admin || user.accessLevel == .Moderator else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    return
                }
                .flatMap { Logic.Comment.getThrowing(by: request.IDComment, on: eventLoop) }
                .flatMap { comment in Logic.Comment.reject(comment: comment, on: eventLoop) }
                .map { _ in Contract.Response() }
        }

        Contract.guarantee(contractRoutine)
    }
}

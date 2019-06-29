import LGNCore
import Generated
import LGNC

/// Rejects and DELETES the comment from storage (rejected premoderation)
public struct RejectCommentController {
    typealias Contract = Services.Quorum.Contracts.RejectComment

    public static func setup() {
        func contractRoutine(
            request: Contract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authenticate(token: request.token, requestInfo: info)
                .mapThrowing { user in
                    guard user.accessLevel == .Admin || user.accessLevel == .Moderator else {
                        throw LGNC.ContractError.GeneralError("Not authenticated", 403)
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

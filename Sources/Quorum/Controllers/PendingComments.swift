import Generated
import LGNCore
import LGNC

class PendingCommentsController {
    public static func setup() {
        typealias Contract = Services.Quorum.Contracts.PendingComments

        func contractRoutine(
            request: Contract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop

            return Logic.User
                .authenticate(token: request.token, requestInfo: info)
                .mapThrowing { user in
                    guard user.isAtLeastModerator else {
                        throw LGNC.ContractError.GeneralError("Not authenticated", 403)
                    }
                    return
                }
                .flatMap { Models.PendingComment.getUnapprovedComments(on: eventLoop) }
                .flatMap { comments in
                    Future.reduce(
                        into: [Services.Shared.Comment](),
                        comments.map { $0.getContractComment(requestInfo: info) },
                        on: eventLoop
                    ) { $0.append($1) }
                }
                .map { Contract.Response(comments: $0) }
        }

        Contract.guarantee(contractRoutine)
    }
}

class PendingCommentsCountController {
    public static func setup() {
        typealias Contract = Services.Quorum.Contracts.PendingCommentsCount

        func contractRoutine(
            request: Contract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop

            return Logic.User
                .authenticate(token: request.token, requestInfo: info)
                .mapThrowing { user in
                    guard user.isAtLeastModerator else {
                        throw LGNC.ContractError.GeneralError("Not authenticated", 403)
                    }
                    return
                }
                .flatMap { Models.PendingComment.getPendingCount(on: eventLoop) }
                .map { Contract.Response(count: $0) }
        }

        Contract.guarantee(contractRoutine)
    }
}

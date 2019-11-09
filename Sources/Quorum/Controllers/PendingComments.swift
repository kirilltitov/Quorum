import Generated
import LGNCore
import LGNC

class PendingCommentsController {
    public static func setup() {
        typealias Contract = Services.Quorum.Contracts.PendingComments

        func contractRoutine(
            request: Contract.Request,
            context: LGNCore.Context
        ) -> Future<Contract.Response> {
            let eventLoop = context.eventLoop

            return Logic.User
                .authenticate(token: request.token, context: context)
                .mapThrowing { user in
                    guard user.isAtLeastModerator else {
                        throw context.errorNotAuthenticated
                    }
                    return
                }
                .flatMap { Models.PendingComment.getUnapprovedComments(on: eventLoop) }
                .flatMap { comments in
                    Future.reduce(
                        into: [Services.Shared.Comment](),
                        comments.map { $0.getContractComment(context: context) },
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
            context: LGNCore.Context
        ) -> Future<Contract.Response> {
            let eventLoop = context.eventLoop

            return Logic.User
                .authenticate(token: request.token, context: context)
                .mapThrowing { user in
                    guard user.isAtLeastModerator else {
                        throw context.errorNotAuthenticated
                    }
                    return
                }
                .flatMap { Models.PendingComment.getPendingCount(on: eventLoop) }
                .map { Contract.Response(count: $0) }
        }

        Contract.guarantee(contractRoutine)
    }
}

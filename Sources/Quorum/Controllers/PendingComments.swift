import Generated
import LGNCore
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.PendingComments

extension Contract.Request: AnyEntityWithSession {}

class PendingCommentsController {
    public static func setup() {
        func contractRoutine(
            request: Contract.Request,
            context: LGNCore.Context
        ) -> EventLoopFuture<Contract.Response> {
            let eventLoop = context.eventLoop

            return Logic.User
                .authenticate(request: request, context: context)
                .mapThrowing { user in
                    guard user.isAtLeastModerator else {
                        throw context.errorNotAuthenticated
                    }
                    return
                }
                .flatMap { Models.PendingComment.getUnapprovedComments(storage: fdb, on: eventLoop) }
                .flatMap { comments in
                    EventLoopFuture.reduce(
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

fileprivate typealias ContractCount = Services.Quorum.Contracts.PendingCommentsCount

extension ContractCount.Request: AnyEntityWithSession {}

class PendingCommentsCountController {
    public static func setup() {

        func contractRoutine(
            request: ContractCount.Request,
            context: LGNCore.Context
        ) -> EventLoopFuture<ContractCount.Response> {
            let eventLoop = context.eventLoop

            return Logic.User
                .authenticate(request: request, context: context)
                .mapThrowing { user in
                    guard user.isAtLeastModerator else {
                        throw context.errorNotAuthenticated
                    }
                    return
                }
                .flatMap { Models.PendingComment.getPendingCount(storage: fdb, on: eventLoop) }
                .map { ContractCount.Response(count: $0) }
        }

        ContractCount.guarantee(contractRoutine)
    }
}

import Generated
import LGNCore
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.PendingComments

extension Contract.Request: AnyEntityWithSession {}

class PendingCommentsController {
    public static func setup() {
        func contractRoutine(request: Contract.Request) async throws -> Contract.Response {
            let user = try await Logic.User.authenticate(request: request)
            guard user.isAtLeastModerator else {
                throw LGNCore.Context.current.errorNotAuthenticated
            }

            let comments = try await Models.PendingComment.getUnapprovedComments()

            return Contract.Response(
                comments: try await comments.map { comment in try await comment.getContractComment() }
            )
        }

        Contract.guarantee(contractRoutine)
    }
}

fileprivate typealias ContractCount = Services.Quorum.Contracts.PendingCommentsCount

extension ContractCount.Request: AnyEntityWithSession {}

class PendingCommentsCountController {
    public static func setup() {
        func contractRoutine(request: ContractCount.Request) async throws -> ContractCount.Response {
            let user = try await Logic.User.authenticate(request: request)
            guard user.isAtLeastModerator else {
                throw LGNCore.Context.current.errorNotAuthenticated
            }

            return ContractCount.Response(count: try await Models.PendingComment.getPendingCount())
        }

        ContractCount.guarantee(contractRoutine)
    }
}

import Foundation
import Generated
import LGNCore
import LGNS
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.EditComment

extension Contract.Request: AnyEntityWithSession {}

public struct EditController {
    public static func setup() {
        Contract.Request.validateIDComment { ID in
            guard try await Logic.Comment.get(by: ID) != nil else {
                return .CommentNotFound
            }
            return nil
        }
        
        func contractRoutine(request: Contract.Request) async throws -> Contract.Response {
            let user = try await Logic.User.authenticate(request: request)

            return try await Logic.Comment.edit(ID: request.IDComment, body: request.body, by: user).getContractComment()
        }

        Contract.guarantee(contractRoutine)
    }
}

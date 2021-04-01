import Foundation
import Generated
import LGNCore
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.LikeComment

extension Contract.Request: AnyEntityWithSession {}

public class LikeController {
    public static func setup() {
        Contract.Request.validateIDComment { ID in
            guard try await Logic.Comment.get(by: ID) != nil else {
                return .CommentNotFound
            }
            return nil
        }

        Contract.guarantee { (request) async throws -> Contract.Response in
            let user = try await Logic.User.authenticate(request: request)

            return Contract.Response(
                likes: try await Logic.Comment.likeOrUnlike(
                    comment: try await Logic.Comment.getThrowing(by: request.IDComment),
                    by: user
                )
            )
        }
    }
}

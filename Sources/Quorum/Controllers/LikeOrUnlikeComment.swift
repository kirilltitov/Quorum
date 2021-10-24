import Foundation
import Generated
import LGNCore
import LGNLog
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.LikeComment

extension Contract.Request: AnyEntityWithSession {}

public class LikeController {
    public static func setup() {
        Contract.Request.validateIDComment { ID in
            guard try await Logic.Comment.get(by: ID) != nil else {
                Logger.current.info("Cannot like comment #\(ID): not found")
                return .CommentNotFound
            }
            return nil
        }

        Contract.guarantee { (request) async throws -> Contract.Response in
            let user = try await Logic.User.authenticate(request: request)

            let likes = try await Logic.Comment.likeOrUnlike(
                comment: try await Logic.Comment.getThrowing(by: request.IDComment),
                by: user
            )

            Logger.current.info("Liked comment #\(request.IDComment), now \(likes) likes")

            return Contract.Response(likes: likes)
        }
    }
}

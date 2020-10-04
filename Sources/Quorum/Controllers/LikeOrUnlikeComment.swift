import Foundation
import Generated
import LGNCore
import LGNC

fileprivate typealias Contract = Services.Quorum.Contracts.LikeComment

extension Contract.Request: AnyEntityWithSession {}

public class LikeController {
    public static func setup() {
        Contract.Request.validateIDComment { ID, eventLoop in
            Logic.Comment
                .get(by: ID, on: eventLoop)
                .map {
                    guard let _: Models.Comment = $0 else {
                        return .CommentNotFound
                    }
                    return nil
                }
        }

        Contract.guarantee { request, context -> EventLoopFuture<Contract.Response> in
            Logic.User
                .authenticate(request: request, context: context)
                .flatMap { user in
                    Logic.Comment
                        .getThrowing(by: request.IDComment, on: context.eventLoop)
                        .map { comment in (user, comment) }
                }
                .flatMap { user, comment in
                    Contract.Response.await(
                        likes: Logic.Comment.likeOrUnlike(comment: comment, by: user, context: context)
                    )
                }
        }
    }
}

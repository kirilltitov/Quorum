import Foundation
import Generated
import LGNCore
import LGNC

public class LikeController {
    typealias Contract = Services.Quorum.Contracts.LikeComment

    public static func setup() {
        Contract.Request.validateIdcomment { ID, eventLoop in
            Logic.Comment
                .get(by: ID, on: eventLoop)
                .map {
                    guard let _: Models.Comment = $0 else {
                        return .CommentNotFound
                    }
                    return nil
                }
        }

        Contract.guarantee { (request, info) -> Future<Contract.Response> in
            let eventLoop = info.eventLoop

            return Logic.User
                .authenticate(token: request.token, requestInfo: info)
                .flatMap { user in
                    Logic.Comment
                        .getThrowing(by: request.IDComment, on: eventLoop)
                        .map { comment in (user, comment) }
                }
                .flatMap { user, comment in
                    Contract.Response.await(
                        likes: Logic.Comment.likeOrUnlike(comment: comment, by: user, on: eventLoop)
                    )
                }
        }
    }
}

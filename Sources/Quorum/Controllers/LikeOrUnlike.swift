import Foundation
import Generated
import LGNCore
import LGNC

public class LikeController {
    typealias LikeContract = Services.Quorum.Contracts.Like

    public static func setup() {
        LikeContract.Request.validateIdcomment { ID, eventLoop in
            Logic.Comment
                .get(by: ID, on: eventLoop)
                .map {
                    guard let _: Models.Comment = $0 else {
                        return .CommentNotFound
                    }
                    return nil
                }
        }

        LikeContract.guarantee { (request, info) -> Future<LikeContract.Response> in
            let eventLoop = info.eventLoop

            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .then { user in
                    Logic.Comment
                        .getThrowing(by: request.IDComment, on: eventLoop)
                        .map { comment in (user, comment) }
                }
                .then { user, comment in
                    LikeContract.Response.await(
                        on: eventLoop,
                        likes: Logic.Comment.likeOrUnlike(comment: comment, by: user, on: eventLoop)
                    )
                }
        }
    }
}

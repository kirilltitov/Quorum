import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

fileprivate typealias Contract = Services.Quorum.Contracts.CreateComment

extension Contract.Request: AnyEntityWithSession {}

public struct CreateController {
    public static func setup() {
        Contract.Request.validateIDPost { ID, eventLoop in
            Logic.Post
                .getPostStatus(ID, on: eventLoop)
                .map { status in
                    if status == .NotFound {
                        return .PostNotFound
                    }
                    if status == .NotCommentable {
                        return .PostIsReadOnly
                    }
                    return nil
                }
        }

        Contract.Request.validateIDReplyComment { ID, eventLoop in
            Logic.Comment
                .doExists(ID: ID, on: eventLoop)
                .map {
                    guard $0 == true else {
                        return .ReplyingCommentNotFound
                    }
                    return nil
                }
        }

        Contract.guarantee { (request: Contract.Request, context: LGNCore.Context) -> EventLoopFuture<Contract.Response> in
            let eventLoop = context.eventLoop
            let user = Logic.User.authenticate(request: request, context: context)

            return Models.Comment.await(
                on: eventLoop,
                ID: Models.Comment.getNextID(storage: fdb, on: eventLoop),
                IDUser: user.map(\.ID),
                IDPost: request.IDPost,
                IDReplyComment: request.IDReplyComment,
                body: Logic.Comment.getProcessedBody(from: request.body)
            )
            .flatMap { comment in user.map { (comment, $0) } }
            .flatMap { comment, user in Logic.Comment.insert(comment: comment, as: user, context: context) }
            .flatMap { comment in comment.getContractComment(context: context) }
        }
    }
}

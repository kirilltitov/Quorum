import Foundation
import Generated
import LGNCore
import LGNC
import LGNS
import Entita2
import NIO

fileprivate typealias Contract = Services.Quorum.Contracts.Comments

extension Contract.Request: AnyEntityWithMaybeSession {}

public struct CommentsController {
    typealias CommentsWithLikesAndUsers = ([Logic.Post.CommentWithLikes], [Models.User.Identifier: Models.User])

    public static func setup() {
        Contract.guarantee { (request: Contract.Request) async throws -> Contract.Response in
            let logger = LGNCore.Context.current.logger

            logger.info("About to load comments with likes for post ID \(request.IDPost)")
            let commentsWithLikes = try await Logic.Post.getCommentsFor(
                ID: request.IDPost,
                as: try await Logic.User.maybeAuthenticate(request: request)
            )

            logger.info("Loaded \(commentsWithLikes.count) comments, about to populate them with users info")

            var users: [Models.User.Identifier: Models.User] = [:]
            for ID in Set(commentsWithLikes.map({ $0.comment.IDUser })) {
                users[ID] = try await Logic.User.get(by: ID) ?? Models.User.unknown
            }

            return Contract.Response(
                comments: commentsWithLikes.map { commentWithLikes in
                    let comment = commentWithLikes.comment
                    let user = users[comment.IDUser] ?? Models.User.unknown

                    return .init(
                        ID: comment.ID,
                        user: Services.Shared.CommentUserInfo(
                            ID: comment.IDUser.string,
                            username: user.username,
                            accessLevel: user.accessLevel.rawValue
                        ),
                        IDPost: comment.IDPostEncoded,
                        IDReplyComment: comment.IDReplyComment,
                        isEditable: comment.isEditable,
                        status: comment.status.rawValue,
                        body: comment.body,
                        likes: commentWithLikes.likes,
                        dateCreated: comment.dateCreated.contractFormatted(),
                        dateUpdated: comment.dateUpdated.contractFormatted()
                    )
                }
            )
        }
    }
}

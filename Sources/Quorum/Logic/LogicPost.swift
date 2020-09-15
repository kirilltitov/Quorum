import Foundation
import Generated
import LGNC
import LGNCore
import Entita2
import FDB
import NIO

public extension Logic {
    enum Post {
        public enum Status: String {
            case OK, NotFound, NotCommentable
        }

        public class CommentWithLikes {
            public let comment: Models.Comment
            private(set) var likes: Int = 0

            public init(_ comment: Models.Comment) {
                self.comment = comment
            }

            func incrementLikes(_ likes: Int = 1) {
                self.likes += likes
            }
        }

        public enum E: Error {
            case PostNotFound
        }

        private static var hashids = Hashids(
            salt: config[.HASHIDS_SALT],
            minHashLength: UInt(config[.HASHIDS_MIN_LENGTH])!
        )

        private static func commentCounterSubspaceForPost(ID: Models.Post.Identifier) -> FDB.Subspace {
            return Models.Post.subspacePrefix[ID]
        }

        public static func decodeHash(ID: String) -> Models.Post.Identifier? {
            return self.hashids.decode(ID).first
        }

        public static func encodeHash(ID: Models.Post.Identifier) -> String {
            return self.hashids.encode(ID) ?? "invalid"
        }

        public static func getPostStatus(_ ID: String, on eventLoop: EventLoop) -> EventLoopFuture<Status> {
            guard let ID = self.decodeHash(ID: ID) else {
                return eventLoop.makeFailedFuture(LGNC.ContractError.GeneralError("Invalid post ID", 400))
            }

            return self.getPostStatus(ID, on: eventLoop)
        }

        public static func updateCommentCounterForPost(
            ID: Models.Post.Identifier,
            count: Int,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Void> {
            return fdb.withTransaction(on: eventLoop) { (transaction: AnyFDBTransaction) in
                transaction
                    .atomic(.add, key: self.commentCounterSubspaceForPost(ID: ID), value: count)
                    .flatMap { $0.commit() }
            }
        }

        public static func incrementCommentCounterForPost(
            ID: Models.Post.Identifier,
            count: Int = 1,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Void> {
            return self.updateCommentCounterForPost(ID: ID, count: count, on: eventLoop)
        }

        public static func decrementCommentCounterForPost(
            ID: Models.Post.Identifier,
            count: Int = -1,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Void> {
            return self.updateCommentCounterForPost(ID: ID, count: count, on: eventLoop)
        }

        public static func getCommentCounterForPost(
            ID: Models.Post.Identifier,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Int> {
            return fdb.withTransaction(on: eventLoop) { (transaction: AnyFDBTransaction) in
                transaction
                    .get(key: self.commentCounterSubspaceForPost(ID: ID), snapshot: true, commit: true)
                    .mapThrowing { (maybeBytes: Bytes?) in
                        guard let bytes = maybeBytes else {
                            return 0
                        }
                        return try bytes.cast()
                    }
            }
        }

        public static func getCommentCountersForPosts(
            IDs: [Models.Post.Identifier],
            on eventLoop: EventLoop
        ) -> EventLoopFuture<[Models.Post.Identifier: Int]> {
            return EventLoopFuture.reduce(
                into: [:],
                IDs.map { ID in
                    self
                        .getCommentCounterForPost(ID: ID, on: eventLoopGroup.eventLoop)
                        .map { (ID, $0) }
                },
                on: eventLoop
            ) { carry, result in
                carry[result.0] = result.1
            }
        }

        public static func getCommentCountersForPosts(
            IDs obfuscatedIDs: [String],
            on eventLoop: EventLoop
        ) -> EventLoopFuture<[String: Int]> {
            return self
                .getCommentCountersForPosts(
                    IDs: obfuscatedIDs
                        .map(self.decodeHash)
                        .compactMap { $0 ?? 0 },
                    on: eventLoop
                )
                .map { results in
                    Dictionary.init(uniqueKeysWithValues: results.map { k, v in (self.encodeHash(ID: k), v) })
                }
        }

        public static func getPostStatus(_ ID: Models.Post.Identifier, on eventLoop: EventLoop) -> EventLoopFuture<Status> {
            let url = "\(config[.WEBSITE_DOMAIN])/post/exists/\(ID)"

            return HTTPRequester
                .requestJSON(
                    method: .GET,
                    url: url,
                    on: eventLoop
                )
                .map { maybeData, _, error in
                    if let error = error {
                        defaultLogger.error("Could not execute remote service API at '\(url)': \(error)")
                        return .NotFound
                    }
                    guard maybeData?[json: "data", "result"] == true else {
                        return .NotFound
                    }

                    return .OK
                }
        }

        public static func getCommentsFor(
            ID: String,
            as maybeUser: Models.User? = nil,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<[CommentWithLikes]> {
            guard let ID = self.decodeHash(ID: ID) else {
                return eventLoop.makeFailedFuture(LGNC.ContractError.GeneralError("Invalid post ID", 400))
            }

            return self.getCommentsFor(ID: ID, as: maybeUser, on: eventLoop)
        }

        public static func getRawCommentsFor(
            ID: Models.Post.Identifier,
            on eventLoop: EventLoop,
            within transaction: AnyFDBTransaction? = nil
        ) -> EventLoopFuture<[(ID: Models.Comment.Identifier, value: Models.Comment)]> {
            return eventLoop
                .makeSucceededFuture()
                .flatMap {
                    guard let transaction = transaction else {
                        return fdb.begin(on: eventLoop)
                    }
                    return eventLoop.makeSucceededFuture(transaction)
                }
                .flatMap { (transaction: AnyFDBTransaction) in
                    Models.Comment.loadAll(
                        bySubspace: Models.Comment._getPostPrefix(ID),
                        within: transaction,
                        snapshot: true,
                        on: eventLoop
                    )
                }
        }

        public static func getCommentsFor(
            ID: Models.Post.Identifier,
            as maybeUser: Models.User? = nil,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<[CommentWithLikes]> {
            return fdb.withTransaction(on: eventLoop) { transaction in
                let isAtLeastModerator = maybeUser != nil && maybeUser?.isAtLeastModerator == true

                return self
                    .getRawCommentsFor(ID: ID, on: eventLoop, within: transaction)
                    .map { results in
                        results
                            .filter { ID, comment in
                                // moderators can see all comments
                                if isAtLeastModerator {
                                    return true
                                }
                                // users can see their own comments
                                if comment.IDUser == maybeUser?.ID {
                                    return true
                                }
                                // author should see own hidden comments as published
                                if comment.status == .hidden && comment.IDUser == maybeUser?.ID {
                                    return true
                                }
                                // if comment isn't published or hidden, don't show it
                                if comment.status => [.pending, .hidden, .banHidden] {
                                    return false
                                }
                                return true
                            }
                            .map { ID, comment in
                                // author should see own hidden comments as published
                                if comment.status == .hidden && comment.IDUser == maybeUser?.ID && !isAtLeastModerator {
                                    comment.status = .published
                                }
                                if comment.status == .deleted && !isAtLeastModerator {
                                    comment.body = ""
                                }
                                return CommentWithLikes(comment)
                            }
                    }
                    .flatMap { commentsWithLikes in
                        Models.Like
                            .getLikesForCommentsIn(postID: ID, within: transaction, on: eventLoop)
                            .map { (commentsWithLikes, $0) }
                    }
                    .map { (commentsWithLikes: [CommentWithLikes], likesInfo: [Models.Comment.Identifier: Int]) in
                        commentsWithLikes.forEach { commentWithLikes in
                            if let likes = likesInfo[commentWithLikes.comment.ID] {
                                commentWithLikes.incrementLikes(likes)
                            }
                        }
                        return commentsWithLikes
                    }
            }
        }
    }
}

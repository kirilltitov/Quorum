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

        public static func getPostStatus(_ ID: String, on eventLoop: EventLoop) -> Future<Status> {
            guard let ID = self.decodeHash(ID: ID) else {
                return eventLoop.makeFailedFuture(LGNC.ContractError.GeneralError("Invalid post ID", 400))
            }

            return self.getPostStatus(ID, on: eventLoop)
        }

        public static func updateCommentCounterForPost(
            ID: Models.Post.Identifier,
            count: Int,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            return fdb.withTransaction(on: eventLoop) { (transaction: FDB.Transaction) in
                transaction
                    .atomic(.add, key: self.commentCounterSubspaceForPost(ID: ID), value: count)
                    .flatMap { $0.commit() }
            }
        }

        public static func incrementCommentCounterForPost(
            ID: Models.Post.Identifier,
            count: Int = 1,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            return self.updateCommentCounterForPost(ID: ID, count: count, on: eventLoop)
        }

        public static func decrementCommentCounterForPost(
            ID: Models.Post.Identifier,
            count: Int = -1,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            return self.updateCommentCounterForPost(ID: ID, count: count, on: eventLoop)
        }

        public static func getCommentCounterForPost(
            ID: Models.Post.Identifier,
            on eventLoop: EventLoop
        ) -> Future<Int> {
            return fdb.withTransaction(on: eventLoop) { (transaction: FDB.Transaction) in
                transaction
                    .get(key: self.commentCounterSubspaceForPost(ID: ID), snapshot: true, commit: true)
                    .map { (maybeBytes: Bytes?) -> Int in
                        guard let bytes = maybeBytes else {
                            return 0
                        }
                        return bytes.cast()
                    }
            }
        }

        public static func getCommentCountersForPosts(
            IDs: [Models.Post.Identifier],
            on eventLoop: EventLoop
        ) -> Future<[Models.Post.Identifier: Int]> {
            return Future.reduce(
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
        ) -> Future<[String: Int]> {
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

        public static func getPostStatus(_ ID: Models.Post.Identifier, on eventLoop: EventLoop) -> Future<Status> {
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
        ) -> Future<[CommentWithLikes]> {
            guard let ID = self.decodeHash(ID: ID) else {
                return eventLoop.makeFailedFuture(LGNC.ContractError.GeneralError("Invalid post ID", 400))
            }

            return self.getCommentsFor(ID: ID, on: eventLoop)
        }

        public static func getCommentsFor(
            ID: Models.Post.Identifier,
            as maybeUser: Models.User? = nil,
            on eventLoop: EventLoop
        ) -> Future<[CommentWithLikes]> {
            return fdb.withTransaction(on: eventLoop) { transaction in
                let rawCommentsProfiler = LGNCore.Profiler.begin()
                let commentsFuture = Models.Comment.loadAll(
                    bySubspace: Models.Comment._getPostPrefix(ID),
                    with: transaction,
                    snapshot: true,
                    on: eventLoop
                )

                commentsFuture.whenComplete { _ in
                    defaultLogger.info("Raw comments loaded in \(rawCommentsProfiler.end().rounded(toPlaces: 4))s")
                }

                let isAtLeastModerator = maybeUser != nil && maybeUser?.isAtLeastModerator == true

                return commentsFuture.map { results in
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
                }.flatMap { commentsWithLikes in
                    Models.Like
                        .getLikesForCommentsIn(postID: ID, with: transaction, on: eventLoop)
                        .map { (commentsWithLikes, $0) }
                }.map { (commentsWithLikes: [CommentWithLikes], likesInfo: [Models.Comment.Identifier: Int]) in
                    commentsWithLikes.forEach { commentWithLikes in
                        if let likes = likesInfo[commentWithLikes.comment.ID] {
                            commentWithLikes.incrementLikes(likes)
                        }
                    }
                    return commentsWithLikes
                }
            }

//        private static let postsLRU: CacheLRU<Int, Models.Post> = CacheLRU(capacity: 1000)
//
//        public static func get(by ID: Int, snapshot: Bool, on eventLoop: EventLoop) -> Future<Models.Post?> {
//            return self.postsLRU.getOrSet(by: ID, on: eventLoop) {
//                Models.Post.loadWithTransaction(
//                    by: ID,
//                    snapshot: snapshot,
//                    on: eventLoop
//                ).map { $0.0 }
//            }
//        }
//
//        public static func getThrowing(
//            by ID: Int,
//            snapshot: Bool,
//            on eventLoop: EventLoop
//        ) -> Future<Models.Post> {
//            return self
//                .get(by: ID, snapshot: snapshot, on: eventLoop)
//                .thenThrowing { maybePost in
//                    guard let post = maybePost else {
//                        throw LGNC.ContractError.GeneralError("Post not found", 404)
//                    }
//                    return post
//                }
//        }
//
        }
    }
}

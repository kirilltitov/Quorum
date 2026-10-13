import Foundation
import Generated
import LGNC
import LGNCore
import LGNLog
import FDB
import FDBEntity

public extension Logic {
    enum Post {
        public enum Status: String {
            case OK, NotFound, NotCommentable
        }

        public struct CommentWithLikes: Sendable {
            public var comment: Models.Comment
            public var likes: Int = 0
        }

        /// Maximum number of posts in a single counters request
        static let maxCountersRequestSize = 100

        private static let hashids = Hashids(
            salt: App.current.config[.HASHIDS_SALT],
            minHashLength: UInt(App.current.config[.HASHIDS_MIN_LENGTH])!
        )

        private static func commentCounterKeyForPost(ID: Models.Post.Identifier) -> FDB.Subspace {
            Models.Post.subspacePrefix[ID]
        }

        public static func decodeHash(ID: String) -> Models.Post.Identifier? {
            let decoded = self.hashids.decode(ID)
            guard decoded.count == 1 else {
                return nil
            }
            return decoded[0]
        }

        public static func encodeHash(ID: Models.Post.Identifier) -> String {
            self.hashids.encode(ID) ?? "invalid"
        }

        public static func getPostStatus(_ ID: String) async throws -> Status {
            guard let ID = self.decodeHash(ID: ID) else {
                throw LGNC.ContractError.GeneralError("Invalid post ID", 400)
            }

            return await self.getPostStatus(ID)
        }

        public static func updateCommentCounterForPost(
            ID: Models.Post.Identifier,
            by count: Int,
            within transaction: borrowing FDB.Transaction
        ) {
            transaction.atomic(.add, key: self.commentCounterKeyForPost(ID: ID), value: Int64(count))
        }

        public static func getCommentCountersForPosts(IDs obfuscatedIDs: [String]) async throws -> [String: Int] {
            guard obfuscatedIDs.count <= self.maxCountersRequestSize else {
                throw LGNC.ContractError.GeneralError("Too many posts", 400)
            }
            let IDs = Set(obfuscatedIDs.compactMap(self.decodeHash))

            return try await App.current.fdb.withTransaction { transaction in
                var result: [String: Int] = [:]
                for ID in IDs {
                    result[self.encodeHash(ID: ID)] = try await transaction
                        .get(key: self.commentCounterKeyForPost(ID: ID), snapshot: true)
                        .value
                        .counterValue
                }
                return result
            }
        }

        public static func getPostStatus(_ ID: Models.Post.Identifier) async -> Status {
            let url = "\(App.current.config[.WEBSITE_DOMAIN])/post/exists/\(ID)"

            do {
                let (maybeData, _) = try await HTTPRequester.requestJSON(method: .GET, url: url)

                guard maybeData?[json: "data", "result"] == true else {
                    return .NotFound
                }

                return .OK
            } catch {
                Logger.current.error("Could not execute remote service API at '\(url)': \(error)")
                return .NotFound
            }
        }

        public static func getRawCommentsFor(
            ID: Models.Post.Identifier,
            within transaction: borrowing FDB.Transaction
        ) async throws -> [Models.Comment] {
            try await Models.Comment.loadAll(in: Models.Comment._getPostPrefix(ID), within: transaction, snapshot: true)
        }

        public static func getCommentsFor(
            ID: String,
            as maybeUser: Models.User? = nil
        ) async throws -> [CommentWithLikes] {
            guard let ID = self.decodeHash(ID: ID) else {
                throw LGNC.ContractError.GeneralError("Invalid post ID", 400)
            }

            return try await self.getCommentsFor(ID: ID, as: maybeUser)
        }

        public static func getCommentsFor(
            ID: Models.Post.Identifier,
            as maybeUser: Models.User? = nil
        ) async throws -> [CommentWithLikes] {
            let isAtLeastModerator = maybeUser?.isAtLeastModerator == true

            return try await App.current.fdb.withTransaction { transaction in
                let likes = try await Models.Like.getLikesForCommentsIn(postID: ID, within: transaction)

                return try await self
                    .getRawCommentsFor(ID: ID, within: transaction)
                    .filter { comment in
                        // moderators can see all comments, users can see their own comments
                        if isAtLeastModerator || comment.IDUser == maybeUser?.ID {
                            return true
                        }
                        // if comment isn't published or deleted, don't show it
                        return !(comment.status => [.pending, .hidden, .banHidden])
                    }
                    .map { comment in
                        var comment = comment
                        // author should see own hidden comments as published
                        if comment.status == .hidden && comment.IDUser == maybeUser?.ID && !isAtLeastModerator {
                            comment.status = .published
                        }
                        if comment.status == .deleted && !isAtLeastModerator {
                            comment.body = ""
                        }
                        return CommentWithLikes(comment: comment, likes: likes[comment.ID] ?? 0)
                    }
            }
        }
    }
}

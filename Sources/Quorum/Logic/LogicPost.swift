import Foundation
import Generated
import LGNC
import LGNCore
import Entita2
import FDB

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
            salt: App.current.config[.HASHIDS_SALT],
            minHashLength: UInt(App.current.config[.HASHIDS_MIN_LENGTH])!
        )

        private static func commentCounterSubspaceForPost(ID: Models.Post.Identifier) -> FDB.Subspace {
            Models.Post.subspacePrefix[ID]
        }

        public static func decodeHash(ID: String) -> Models.Post.Identifier? {
            self.hashids.decode(ID).first
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

        public static func updateCommentCounterForPost(ID: Models.Post.Identifier, count: Int) async throws {
            try await App.current.fdb.withTransaction { (transaction: AnyFDBTransaction) in
                transaction.atomic(.add, key: self.commentCounterSubspaceForPost(ID: ID), value: count)
                try await transaction.commit()
            }
        }

        public static func incrementCommentCounterForPost(ID: Models.Post.Identifier, count: Int = 1) async throws {
            try await self.updateCommentCounterForPost(ID: ID, count: count)
        }

        public static func decrementCommentCounterForPost(ID: Models.Post.Identifier, count: Int = -1) async throws {
            try await self.updateCommentCounterForPost(ID: ID, count: count)
        }

        public static func getCommentCounterForPost(ID: Models.Post.Identifier) async throws -> Int {
            try await App.current.fdb.withTransaction { (transaction: AnyFDBTransaction) in
                guard let bytes = try await transaction.get(key: self.commentCounterSubspaceForPost(ID: ID), snapshot: true) else {
                    return 0
                }
                return try bytes.cast()
            }
        }

        public static func getCommentCountersForPosts(
            IDs: [Models.Post.Identifier]
        ) async throws -> [Models.Post.Identifier: Int] {
            var result: [Models.Post.Identifier: Int] = [:]

            for ID in IDs {
                result[ID] = try await self.getCommentCounterForPost(ID: ID)
            }

            return result
        }

        public static func getCommentCountersForPosts(IDs obfuscatedIDs: [String]) async throws -> [String: Int] {
            let counters = try await self.getCommentCountersForPosts(
                IDs: obfuscatedIDs
                    .map(self.decodeHash)
                    .compactMap { $0 ?? 0 }
            )

            return Dictionary.init(uniqueKeysWithValues: counters.map { k, v in (self.encodeHash(ID: k), v) })
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
                LGNCore.Context.current.logger.error("Could not execute remote service API at '\(url)': \(error)")
                return .NotFound
            }
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

        public static func getRawCommentsFor(
            ID: Models.Post.Identifier,
            within maybeTransaction: AnyFDBTransaction? = nil
        ) async throws -> [(ID: Models.Comment.Identifier, value: Models.Comment)] {
            try await Models.Comment.loadAll(
                bySubspace: Models.Comment._getPostPrefix(ID),
                within: try maybeTransaction ?? App.current.fdb.begin(),
                snapshot: true
            )
        }

        public static func getCommentsFor(
            ID: Models.Post.Identifier,
            as maybeUser: Models.User? = nil
        ) async throws -> [CommentWithLikes] {
            try await App.current.fdb.withTransaction { transaction in
                let isAtLeastModerator = maybeUser != nil && maybeUser?.isAtLeastModerator == true

                let commentsWithLikes = try await self
                    .getRawCommentsFor(ID: ID, within: transaction)
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
                    .map { (ID: Models.Comment.Identifier, comment: Models.Comment) -> CommentWithLikes in
                        // author should see own hidden comments as published
                        if comment.status == .hidden && comment.IDUser == maybeUser?.ID && !isAtLeastModerator {
                            comment.status = .published
                        }
                        if comment.status == .deleted && !isAtLeastModerator {
                            comment.body = ""
                        }
                        return CommentWithLikes(comment)
                    }

                let likesInfo = try await Models.Like.getLikesForCommentsIn(postID: ID, within: transaction)

                for comment in commentsWithLikes {
                    if let likes = likesInfo[comment.comment.ID] {
                        comment.incrementLikes(likes)
                    }
                }

                return commentsWithLikes
            }
        }
    }
}

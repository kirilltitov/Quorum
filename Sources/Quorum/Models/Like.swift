import LGNCore
import LGNLog
import FDB
import FDBEntity

public extension Models {
    /// Likes of comments. Keys (in the main subspace):
    /// * `Like / post / <post ID> / Comment / <comment ID> / <user ID>`: like of a user
    /// * `Like / cnt / post / <post ID> / Comment / <comment ID>`: likes counter of a comment
    /// * user's "index of index" entry `Like / <comment ID>`: likes of a user
    enum Like {
        public static let entityName = "Like"

        public static var subspacePrefix: FDB.Subspace {
            App.current.subspaceMain[Self.entityName]
        }

        static func getLikesCounterPrefixSubspace(forPostID ID: Post.Identifier) -> FDB.Subspace {
            self.subspacePrefix["cnt"][Post.entityName][ID]
        }

        static func getLikesCounterSubspaceFor(comment: Comment) -> FDB.Subspace {
            self.getLikesCounterPrefixSubspace(forPostID: comment.IDPost)[Comment.entityName][comment.ID]
        }

        static func getCommentsLikesPrefix(for comment: Comment) -> FDB.Subspace {
            self.subspacePrefix[Post.entityName][comment.IDPost][Comment.entityName][comment.ID]
        }

        public static func getLikesFor(comment: Comment) async throws -> Int {
            try await App.current.fdb.get(key: self.getLikesCounterSubspaceFor(comment: comment), snapshot: true)
                .counterValue
        }

        public static func getLikesForCommentsIn(
            postID: Post.Identifier,
            within transaction: borrowing FDB.Transaction
        ) async throws -> [Comment.Identifier: Int] {
            let prefix = self.getLikesCounterPrefixSubspace(forPostID: postID)
            var result = [Comment.Identifier: Int]()

            for record in try await transaction.getAll(prefix.range, snapshot: true) {
                guard
                    let tuple = try? prefix.unpack(record.key),
                    let (_, ID) = try? tuple.unpack(as: String.self, Int.self)
                else {
                    continue
                }
                result[ID] = record.value.counterValue
            }

            return result
        }

        /// Likes the comment, or unlikes it if it's already liked by the user. Returns the new number of likes.
        public static func likeOrUnlike(comment: Comment, by user: User) async throws -> Int {
            let commentLikeKey = self.getCommentsLikesPrefix(for: comment)[user.ID]
            let userLikeIndexKey = user.getIndexIndexKeyForIndex(key: .Like, value: comment.ID)
            let counterKey = self.getLikesCounterSubspaceFor(comment: comment)

            return try await App.current.fdb.withTransaction { transaction in
                let likes = transaction.get(key: counterKey, snapshot: true)
                let delta: Int64
                if try await transaction.get(key: commentLikeKey).value == nil {
                    transaction.set(key: commentLikeKey, value: [])
                    transaction.set(key: userLikeIndexKey, value: [])
                    delta = 1
                } else {
                    transaction.clear(key: commentLikeKey)
                    transaction.clear(key: userLikeIndexKey)
                    delta = -1
                }
                transaction.atomic(.add, key: counterKey, value: delta)
                return try await likes.value.counterValue + Int(delta)
            }
        }
    }
}

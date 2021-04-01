import LGNCore
import Entita2FDB

// not to be created at all
public extension Models {
    final class Like: ModelInt {
        public static var IDKey: KeyPath<Like, Int> = \.ID

        public static var fullEntityName = false
        public static var storage = fdb

        public let ID: Int

        fileprivate init(ID: Int) {
            self.ID = ID
        }

        fileprivate static func getLikesCounterPrefixSubspace(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.subspacePrefix["cnt"][Post.entityName][ID]
        }

        fileprivate static func getLikesCounterSubspaceFor(comment: Comment) -> FDB.Subspace {
            return self.getLikesCounterPrefixSubspace(forPostID: comment.IDPost)[Comment.entityName][comment.ID]
        }

        /* fileprivate */ public static func getRootPrefix() -> FDB.Subspace {
            return self.subspacePrefix[Post.entityName]
        }

        fileprivate static func getRootPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.getRootPrefix()[ID]
        }

        fileprivate static func getRootCommentsPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.getRootPrefix(forPostID: ID)[Comment.entityName]
        }

        fileprivate static func getCommentsLikesPrefix(for comment: Comment) -> FDB.Subspace {
            return self.getRootCommentsPrefix(forPostID: comment.IDPost)[comment.ID]
        }

        fileprivate static func getPostLikesPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.getRootPrefix(forPostID: ID)[Post.entityName]
        }

        public static func getCommentID(from tuple: FDB.Tuple) -> Models.Comment.Identifier? {
            guard tuple.tuple.count >= 3 else {
                return nil
            }
            guard let value = tuple.tuple[tuple.tuple.count - 3] as? Models.Comment.Identifier else {
                return nil
            }
            return value
        }

        fileprivate static func unwrapLikeCountFrom(maybeBytes: Bytes?) -> Int {
            guard let bytes = maybeBytes else {
                return 0
            }
            do {
                return try bytes.cast()
            } catch {
                defaultLogger.error("Could not unwrap Int from bytes \(bytes)")
                return 0
            }
        }

        public static func getLikesFor(comment: Comment) async throws -> Int {
            try await self.unwrapLikeCountFrom(
                maybeBytes: fdb
                    .begin()
                    .get(key: self.getLikesCounterSubspaceFor(comment: comment), snapshot: true)
            )
        }

        public static func getLikesForCommentsIn(
            postID: Int,
            within transaction: AnyFDBTransaction
        ) async throws -> [Comment.Identifier: Int] {
            let records = try await transaction.get(
                range: self.getLikesCounterPrefixSubspace(forPostID: postID).range,
                snapshot: true
            )

            var result = [Comment.Identifier: Int]()

            // Can't use results.records.map because skipping rows becomes unreasonably more difficult
            for record in records.records {
                guard
                    let tuple = try? FDB.Tuple(from: record.key).tuple.compactMap({$0}),
                    let ID = tuple.last as? Comment.Identifier
                    else { continue }
                result[ID] = self.unwrapLikeCountFrom(maybeBytes: record.value)
            }

            return result
        }

        public static func getLikesFor(comment: Comment, user: User) async throws -> (Models.Comment, Int, Models.User) {
            (comment, try await self.getLikesFor(comment: comment), user)
        }

        public static func likeOrUnlike(comment: Comment, by user: User) async throws -> Int {
            try await self.processLikeTo(comment: comment, by: user)
            return try await self.getLikesFor(comment: comment)
        }

        fileprivate static func updateLikesCounterFor(
            comment: Comment,
            count: Int,
            within transaction: AnyFDBTransaction
        ) {
            transaction.atomic(.add, key: self.getLikesCounterSubspaceFor(comment: comment), value: count)
        }

        /* fileprivate */
        public static func incrementLikesCounterFor(comment: Comment, within transaction: AnyFDBTransaction) {
            self.updateLikesCounterFor(comment: comment, count: 1, within: transaction)
        }

        fileprivate static func decrementLikesCounterFor(comment: Comment, within transaction: AnyFDBTransaction) {
            self.updateLikesCounterFor(comment: comment, count: -1, within: transaction)
        }

        fileprivate static func processLikeTo(
            comment: Comment,
            by user: User
        ) async throws {
            let commentLikeKey = self.getCommentsLikesPrefix(for: comment)[user.ID]
            let userLikeIndexKey = user.getIndexIndexKeyForIndex(key: .Like, value: comment.ID)

            try await fdb.withTransaction { transaction in
                if try await transaction.get(key: self.getCommentsLikesPrefix(for: comment)[user.ID]) == nil {
                    transaction.set(key: commentLikeKey, value: [])
                    transaction.set(key: userLikeIndexKey, value: [])
                    self.incrementLikesCounterFor(comment: comment, within: transaction)
                } else {
                    transaction.clear(key: commentLikeKey)
                    transaction.clear(key: userLikeIndexKey)
                    self.decrementLikesCounterFor(comment: comment, within: transaction)
                }

                try await transaction.commit()
            }
        }
    }
}
